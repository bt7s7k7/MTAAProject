import Invite from '#models/invite'
import User from '#models/user'

export class UserRepository {
  async isFriendsWith(user: User, friend: User) {
    const result = await user.related('friends').pivotQuery().where('friend_id', friend.id).first()
    return !!result
  }

  async searchUsers(query: string) {
    const limit = 10
    return await User.query().whereILike('full_name', query).limit(limit)
  }

  async sendInvite(from: User, to: User) {
    // TODO
    return null! as Invite
  }

  async acceptInvite(invite: Invite) {
    // TODO
  }
}
