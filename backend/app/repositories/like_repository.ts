import Activity from '#models/activity'
import Like from '#models/like'
import { UserEventRouter } from '#services/user_event_router'
import { inject } from '@adonisjs/core'
import { Exception } from '@adonisjs/core/exceptions'

/** Class for liking and unliking activities */
@inject()
export class LikesRepository {
  constructor(protected eventRouter: UserEventRouter) {}

  /** Adds a like to an activity */
  async createLike(userId: number, activityId: number) {
    const prevActivity = await Activity.query().where('id', activityId).firstOrFail()
    if (prevActivity.userId === userId) {
      throw new Exception('Cannot like your own activity', { status: 409 })
    }

    const existingLike = await Like.query()
      .where('user_id', userId)
      .andWhere('activity_id', activityId)
      .first()

    if (existingLike) {
      throw new Exception('User has already liked this activity', { status: 409 })
    }

    const like = new Like()
    like.userId = userId
    like.activityId = activityId

    await like.save()

    const activity = await Activity.query()
      .preload('user')
      .preload('likes')
      .where('id', activityId)
      .firstOrFail()

    this.eventRouter.notifyUserAndFriends(userId, {
      type: 'activity',
      id: activity.id,
      value: {
        ...activity.serialize(),
        likesCount: activity.likes.length,
        hasLiked: false,
        path: null,
      },
    })
  }

  /** Returns if the user has already liked an activity */
  async userHasLikedActivity(userId: number, activityId: number) {
    const like = await Like.query()
      .where('userId', userId)
      .andWhere('activityId', activityId)
      .first()
    return !!like
  }

  /** Removes a like from an activity */
  async deleteLike(userId: number, activityId: number) {
    const like = await Like.query()
      .where('user_id', userId)
      .andWhere('activity_id', activityId)
      .first()

    if (!like) {
      throw new Exception('User has not yet liked this activity', { status: 404 })
    }

    await like.delete()

    const activity = await Activity.query()
      .preload('user')
      .preload('likes')
      .where('id', activityId)
      .firstOrFail()

    this.eventRouter.notifyUserAndFriends(userId, {
      type: 'activity',
      id: activity.id,
      value: {
        ...activity.serialize(),
        likesCount: activity.likes.length,
        hasLiked: false,
        path: null,
      },
    })
  }
}
