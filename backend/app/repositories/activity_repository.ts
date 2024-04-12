import Activity from '#models/activity'
import User from '#models/user'
import { UserEventRouter } from '#services/user_event_router'
import { activityValidator } from '#validators/activity_validator'
import { inject } from '@adonisjs/core'
import { Infer } from '@vinejs/vine/types'

@inject()
export class ActivityRepository {
  constructor(protected eventRouter: UserEventRouter) {}

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

  async storeActivity(user: User, data: Infer<typeof activityValidator>) {
    const activity = await user.related('activities').create(data)
    // @ts-ignore
    activity.user = user

    this.eventRouter.notifyUserAndFriends(user.id, {
      type: 'activity',
      id: activity.id,
      value: activity.serialize(),
    })

    return activity
  }

  async destroyActivity(activityId: number, userId: number) {
    const activity = await Activity.query()
      .where('id', activityId)
      .where('userId', userId)
      .preload('user')
      .firstOrFail()

    await activity.delete()

    this.eventRouter.notifyUserAndFriends(userId, {
      type: 'activity',
      id: activityId,
      value: null,
    })
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
}
