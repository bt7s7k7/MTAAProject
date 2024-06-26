import Invite from '#models/invite'
import User from '#models/user'
import { UserEventRouter } from '#services/user_event_router'
import { userUpdateValidator } from '#validators/user_validator'
import { inject } from '@adonisjs/core'
import { MultipartFile } from '@adonisjs/core/bodyparser'
import { Exception } from '@adonisjs/core/exceptions'
import app from '@adonisjs/core/services/app'
import { Infer } from '@vinejs/vine/types'
import { mkdir } from 'node:fs/promises'
import { LevelRepository } from './level_repository.js'
import { NotificationRepository } from './notification_repository.js'

/** Class for managing users and their friendships */
@inject()
export class UserRepository {
  constructor(
    protected eventRouter: UserEventRouter,
    protected notificationRepository: NotificationRepository,
    protected levelRepository: LevelRepository
  ) {}

  /** Returns if a user is friends with an another user */
  async isFriendsWith(user: User, friend: User) {
    const result = await user.related('friends').pivotQuery().where('friend_id', friend.id).first()
    return !!result
  }

  /** Searches users by a query, limiting result size */
  async searchUsers(query: string) {
    const limit = 10
    return await User.query().whereILike('fullName', `%${query}%`).limit(limit)
  }

  protected _iconsPath: string | null = null
  /** Gets path to icon upload folder */
  async getIconsPath() {
    if (this._iconsPath === null) {
      this._iconsPath = app.makePath('uploads', 'icons')
      await mkdir(this._iconsPath, { recursive: true }).catch((error) => {
        if (error.code === 'EEXIST') return null
        throw error
      })
    }

    return this._iconsPath
  }

  /** Sends an invite from one user to another */
  async sendInvite(from: User, to: User) {
    const existing = await Invite.query()
      .where('receiverId', to.id)
      .where('senderId', from.id)
      .first()

    if (existing) throw new Exception('Invite already sent', { status: 400 })
    if (await this.isFriendsWith(from, to)) throw new Exception('Already a friend', { status: 400 })

    // Testing if target user haven't sent an invite to the requesting user
    const counter = await Invite.query()
      .where('receiverId', from.id)
      .where('senderId', to.id)
      .first()

    if (counter) {
      this.acceptInvite(counter)
      return 'accepted'
    }

    const invite = await Invite.create({ receiverId: to.id, senderId: from.id })
    // @ts-ignore
    invite.sender = from
    // @ts-ignore
    invite.receiver = to

    this.eventRouter.notifyUser(to.id, {
      type: 'invite',
      id: invite.sender.id,
      value: invite.sender.serialize(),
    })

    this.notificationRepository.sendNotificationUser(to, {
      title: 'Friendship invitation',
      body: `User ${from.fullName} has invited you to become friends`,
      route: 'Friend',
    })

    return 'sent'
  }

  /** Accepts an invite */
  async acceptInvite(invite: Invite) {
    await Promise.all([invite.load('receiver'), invite.load('sender')])

    const from = invite.sender
    const to = invite.receiver
    await this.addFriendship(from, to)
    await invite.delete()

    this.eventRouter.notifyUser(to.id, {
      type: 'invite',
      id: invite.sender.id,
      value: null,
    })

    this.notificationRepository.sendNotificationUser(from, {
      title: 'Friendship accepted',
      body: `User ${to.fullName} has accepted your invite`,
      route: 'Friend',
    })
  }

  /** Denies an invite */
  async denyInvite(invite: Invite) {
    await Promise.all([invite.load('receiver'), invite.load('sender')])

    const from = invite.sender
    const to = invite.receiver
    await invite.delete()

    this.eventRouter.notifyUser(invite.receiverId, {
      type: 'invite',
      id: invite.senderId,
      value: null,
    })

    this.notificationRepository.sendNotificationUser(from, {
      title: 'Friendship rejected',
      body: `User ${to.fullName} has rejected your invite`,
      route: 'Friend',
    })
  }

  /** Adds a friendship between users */
  async addFriendship(from: User, to: User) {
    await Promise.all([
      from.related('friends').attach([to.id]),
      to.related('friends').attach([from.id]),
    ])
    this.eventRouter.updateFriendshipState(from.id, to.id, 'added')

    this.eventRouter.notifyUser(from.id, {
      type: 'friend',
      id: to.id,
      value: to.serialize(),
    })

    this.eventRouter.notifyUser(to.id, {
      type: 'friend',
      id: from.id,
      value: from.serialize(),
    })
  }

  /** Removes a friendship between users */
  async removeFriendship(from: User, to: User) {
    if (!this.isFriendsWith(from, to)) throw new Exception('Not friends', { status: 400 })

    await Promise.all([
      from.related('friends').detach([to.id]),
      to.related('friends').detach([from.id]),
    ])

    this.eventRouter.updateFriendshipState(from.id, to.id, 'removed')

    this.eventRouter.notifyUser(from.id, {
      type: 'friend',
      id: to.id,
      value: null,
    })

    this.eventRouter.notifyUser(to.id, {
      type: 'friend',
      id: from.id,
      value: null,
    })
  }

  /** Handles a user uploading an icon */
  async uploadIcon(user: User, photo: MultipartFile) {
    await photo.move(`./uploads/users/${user.id}`, {
      name: `profile.${photo.extname}`, // Save with a custom name
    })

    user.icon = `uploads/users/${user.id}/profile.${photo.extname}?t=${Math.random()}`
    await user.save()

    this.eventRouter.notifyUserAndFriends(user.id, {
      type: 'user',
      id: user.id,
      value: user.serialize(),
    })
  }

  /** Updates user profile */
  async updateUser(user: User, data: Infer<typeof userUpdateValidator>) {
    for (const [key, value] of Object.entries(data)) {
      if (value === '' || value === null) {
        continue
      }
      const original = user[key as keyof typeof user]
      console.log({ original, value, key })
      if (original !== value) {
        void ((user as any)[key] = value)
      }
    }

    await user.save()

    this.eventRouter.notifyUserAndFriends(user.id, {
      type: 'user',
      id: user.id,
      value: user.serialize(),
    })
  }

  /** Adds a points to a user, automatically levelling up  */
  async addPoints(user: User, points: number): Promise<void> {
    user.points += points // Pridaj body k existujúcemu počtu

    const targetLevel = await this.levelRepository.getLevelByPoints(user.points)
    const currLevelID = user.levelId
    if (currLevelID !== targetLevel.id) {
      user.levelId = targetLevel.id
    }

    await user.save()

    this.eventRouter.notifyUserAndFriends(user.id, {
      type: 'user',
      id: user.id,
      value: user.serialize(),
    })
  }
}
