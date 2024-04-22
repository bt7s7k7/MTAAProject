import Activity from '#models/activity'
import User from '#models/user'
import { UserEventRouter } from '#services/user_event_router'
import { activityValidator } from '#validators/activity_validator'
import { inject } from '@adonisjs/core'
import { Infer } from '@vinejs/vine/types'
import { NotificationRepository } from './notification_repository.js'
import { UserRepository } from './user_repository.js'

@inject()
export class ActivityRepository {
  constructor(
    protected eventRouter: UserEventRouter,
    protected notificationRepository: NotificationRepository,
    protected userRepository: UserRepository // Inject the UserRepository here
  ) {}

  async findAllUserAndFriendsActivities(userId: number) {
    const activities = await Activity.query()
      .leftJoin('users_friends', 'activities.user_id', 'users_friends.user_id')
      .where('activities.user_id', userId)
      .orWhere('users_friends.friend_id', userId)
      .preload('likes')
      .preload('user')
      .orderBy('activities.created_at', 'desc')
      .select('activities.*')

    return activities
  }

  async findUserActivitiesById(userId: number) {
    return Activity.query()
      .where('userId', userId)
      .preload('user')
      .preload('likes')
      .orderBy('activities.created_at', 'desc')
      .select('activities.*')
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
    const pointsForActivity = this.calculatePointsForActivity(data.steps) // Assume `data` has `steps`
    await this.userRepository.addPoints(user, pointsForActivity)
    // @ts-ignore
    activity.user = user

    this.eventRouter.notifyUserAndFriends(user.id, {
      type: 'activity',
      id: activity.id,
      value: {
        ...activity.serialize(),
        hasLiked: false,
        likesCount: 0,
      },
    })

    this.notificationRepository.sendNotificationUserFriends(user, {
      title: data.activityName,
      body: `User ${user.fullName} has submitted a new activity`,
      route: '',
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

  calculatePointsForActivity(steps: number): number {
    return steps
  }
}
