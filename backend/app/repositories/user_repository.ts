import Invite from '#models/invite'
import User from '#models/user'
import { Exception } from '@adonisjs/core/exceptions'
import app from '@adonisjs/core/services/app'
import { mkdir } from 'node:fs/promises'

export class UserRepository {
  async isFriendsWith(user: User, friend: User) {
    const result = await user.related('friends').pivotQuery().where('friend_id', friend.id).first()
    return !!result
  }

  async searchUsers(query: string) {
    const limit = 10
    return await User.query().whereILike('fullName', `%${query}%`).limit(limit)
  }

  protected _iconsPath: string | null = null
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

    await Invite.create({ receiverId: to.id, senderId: from.id })
    // TODO: sent notification
    return 'sent'
  }

  async acceptInvite(invite: Invite) {
    await Promise.all([invite.load('receiver'), invite.load('sender')])

    const from = invite.sender
    const to = invite.receiver
    await this.addFriendship(from, to)
    await invite.delete()
    // TODO: send notification
  }

  async denyInvite(invite: Invite) {
    await invite.delete()
    // TODO: send notification
  }

  async addFriendship(from: User, to: User) {
    await Promise.all([
      from.related('friends').attach([to.id]),
      to.related('friends').attach([from.id]),
    ])
    // TODO send notifications
  }

  async removeFriendship(from: User, to: User) {
    if (!this.isFriendsWith(from, to)) throw new Exception('Not friends', { status: 400 })
    await Promise.all([
      from.related('friends').detach([to.id]),
      to.related('friends').detach([from.id]),
    ])
    // TODO send notifications
  }
}
