import Like from '#models/like'

export class LikesRepository {
  async createLike(userId: number, activityId: number): Promise<Like> {
    const existingLike = await Like.query()
      .where('user_id', userId)
      .andWhere('activity_id', activityId)
      .first()

    if (existingLike) {
      throw new Error('User has already liked this activity.')
    }

    const like = new Like()
    like.userId = userId
    like.activityId = activityId

    await like.save()

    return like
  }

  async deleteLike(userId: number, activityId: number): Promise<boolean> {
    const like = await Like.query()
      .where('user_id', userId)
      .andWhere('activity_id', activityId)
      .first()

    if (!like) {
      throw new Error('Like does not exist.')
    }

    await like.delete()

    return true
  }
}
