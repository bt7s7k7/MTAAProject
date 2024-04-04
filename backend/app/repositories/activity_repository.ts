// repositories/ActivityRepository.ts
import Activity from '#models/activity'
import User from '#models/user'

export class ActivityRepository {
  async findAllUserAndFriendsActivities(userId: number) {
    const user = await User.query()
      .where('id', userId)
      .preload('activities')
      .preload('friends', (friendsQuery) => {
        friendsQuery.preload('activities')
      })
      .firstOrFail()

    const activities = user.activities
    user.friends.forEach((friend) => {
      activities.push(...friend.activities)
    })

    return activities
  }

  async findUserActivitiesById(userId: number) {
    return Activity.query().where('userId', userId)
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
