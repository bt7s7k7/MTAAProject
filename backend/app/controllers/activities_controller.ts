import User from '#models/user'
import { activityValidator } from '#validators/activity_validator'
import { inject } from '@adonisjs/core'
import { Exception } from '@adonisjs/core/exceptions'
import { HttpContext } from '@adonisjs/core/http'
import { ActivityRepository } from '../repositories/activity_repository.js'
import { LikesRepository } from '../repositories/like_repository.js'
import { UserRepository } from '../repositories/user_repository.js'

export const test = 5

@inject()
export default class ActivityController {
  constructor(
    protected activityRepository: ActivityRepository,
    protected userRepository: UserRepository,
    protected likesRepository: LikesRepository
  ) {}

  async index({ auth }: HttpContext) {
    const user = auth.user!
    const activities = await this.activityRepository.findAllUserAndFriendsActivities(user.id)

    const activitiesWithLikeStatus = await Promise.all(
      activities.map(async (activity) => {
        return {
          ...activity.serialize(),
          likesCount: activity.likes.length,
          hasLiked: await this.likesRepository.userHasLikedActivity(user.id, activity.id),
          path: null,
        }
      })
    )

    return activitiesWithLikeStatus
  }

  async userActivities({ auth, params }: HttpContext) {
    const currentUser = auth.user!
    const targetUserId = Number.parseInt(params.id)

    if (currentUser.id !== targetUserId) {
      const targetUser = await User.findOrFail(targetUserId)
      if (!(await this.userRepository.isFriendsWith(currentUser, targetUser))) {
        throw new Exception('Access Denied: User is not a friend or the user themself.', {
          status: 403,
        })
      }
    }

    const activities = await this.activityRepository.findUserActivitiesById(targetUserId)
    return Promise.all(
      activities.map(async (activity) => {
        return {
          ...activity.serialize(),
          likesCount: activity.likes.length,
          hasLiked: await this.likesRepository.userHasLikedActivity(currentUser.id, activity.id),
          path: null,
        }
      })
    )
  }

  async activityDetails({ auth, params }: HttpContext) {
    const user = auth.user!
    const activityId = Number.parseInt(params.id)
    const activity = await this.activityRepository.findActivityDetails(user.id, activityId)

    return {
      ...activity.serialize(),
      likesCount: activity.likes.length,
      hasLiked: await this.likesRepository.userHasLikedActivity(user.id, activity.id),
    }
  }

  async deleteActivity({ auth, params }: HttpContext) {
    const user = auth.user!
    const id = Number(params.id)
    await this.activityRepository.destroyActivity(id, user.id)
  }

  async store({ auth, request }: HttpContext) {
    const user = auth.user!
    const activityData = await activityValidator.validate(request.all())
    const activity = await this.activityRepository.storeActivity(user, activityData)

    return {
      ...activity.serialize(),
      likesCount: 0,
      hasLiked: false,
    }
  }

  async like({ auth, params }: HttpContext) {
    const userId = auth.user!.id
    const id = Number(params.id)

    await this.likesRepository.createLike(userId, id)
  }

  async unlike({ auth, params }: HttpContext) {
    const userId = auth.user!.id
    const id = Number(params.id)

    await this.likesRepository.deleteLike(userId, id)
  }
}
