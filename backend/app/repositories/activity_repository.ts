import Activity from '#models/activity'
import User from '#models/user'
import { UserEventRouter } from '#services/user_event_router'
import { activityValidator } from '#validators/activity_validator'
import { inject } from '@adonisjs/core'
import { Exception } from '@adonisjs/core/exceptions'
import { Infer } from '@vinejs/vine/types'
import { NotificationRepository } from './notification_repository.js'
import { UserRepository } from './user_repository.js'

/** Class for getting and creating activities */
@inject()
export class ActivityRepository {
  constructor(
    protected eventRouter: UserEventRouter,
    protected notificationRepository: NotificationRepository,
    protected userRepository: UserRepository
  ) {}

  /** Finds all activities for a user and their friends */
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

  /** Finds all activities for a user */
  async findUserActivitiesById(userId: number) {
    return Activity.query()
      .where('userId', userId)
      .preload('user')
      .preload('likes')
      .orderBy('activities.created_at', 'desc')
  }

  /** Returns details about a specific activity */
  async findActivityDetails(userId: number, activityId: number) {
    const activity = await Activity.query()
      .where('id', activityId)
      .preload('user', (v) => v.preload('friends'))
      .preload('likes')
      .firstOrFail()

    if (
      activity.userId === userId ||
      activity.user.friends.find((friend) => friend.id === userId)
    ) {
      return activity
    } else {
      throw new Exception('Not authorized to view this activity', { status: 403 })
    }
  }

  /** Creates a new activity */
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
        path: null,
      },
    })

    this.notificationRepository.sendNotificationUserFriends(user, {
      title: data.activityName,
      body: `User ${user.fullName} has submitted a new activity`,
      route: '',
    })

    return activity
  }

  /** Destroys an activity */
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

  protected calculatePointsForActivity(steps: number): number {
    return steps
  }
}
