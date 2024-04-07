// repositories/ActivityRepository.ts
import Activity from '#models/activity'
import User from '#models/user'

export class ActivityRepository {
  async findAllUserAndFriendsActivities(userId: number) {
    const user = await User.query()
      .where('id', userId)
      .preload('activities', (query) => query.preload('user'))
      .preload('friends', (friendsQuery) => {
        friendsQuery.preload('activities', (query) => query.preload('user'))
      })
      .firstOrFail()

    const activities = user.activities.concat(user.friends.flatMap((v) => v.activities))

    return activities
  }

  async findUserActivitiesById(userId: number) {
    return Activity.query().where('userId', userId).preload('user')
  }

  async findActivityDetails(userId: number, activityId: number) {
    const activity = await Activity.query().where('id', activityId).preload('user').firstOrFail()

    if (
      activity.userId === userId ||
      activity.user.friends.find((friend) => friend.id === userId)
    ) {
      return activity
    } else {
      throw new Error('Not authorized to view this activity')
    }
  }

  async storeActivity(data: any, userId: number) {
    const user = await User.findOrFail(userId)
    return await user.related('activities').create(data)
  }

  async destroyActivity(activityId: number, userId: number) {
    const activity = await Activity.query()
      .where('id', activityId)
      .where('userId', userId)
      .firstOrFail()

    await activity.delete()
  }

  async updateActivity(activityId: number, userId: number, data: any) {
    const activity = await Activity.query()
      .where('id', activityId)
      .where('userId', userId)
      .firstOrFail()

    activity.merge(data)
    await activity.save()
    return activity
  }

  async createActivity(userId: number, data: any) {
    return await this.storeActivity(data, userId)
  }
}
