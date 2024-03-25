import User from '#models/user'

export class UserRepository {
  async isFriendsWith(user: User, friend: User) {
    const result = await user.related('friends').pivotQuery().where('friend_id', friend.id).first()
    return !!result
  }
}
