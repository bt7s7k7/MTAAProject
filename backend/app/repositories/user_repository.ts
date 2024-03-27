import Invite from '#models/invite'
import User from '#models/user'
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
    // TODO
    return null! as Invite
  }

  async acceptInvite(invite: Invite) {
    // TODO
  }

  async denyInvite(invite: Invite) {
    // TODO
  }
}
