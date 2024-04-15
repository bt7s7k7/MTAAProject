import User from '#models/user'
import { activityValidator } from '#validators/activity_validator'
import { likeValidator } from '#validators/like_validator'
import { inject } from '@adonisjs/core'
import { Exception } from '@adonisjs/core/exceptions'
import { HttpContext } from '@adonisjs/core/http'
import { ActivityRepository } from '../repositories/activity_repository.js'
import { LikesRepository } from '../repositories/like_repository.js'
import { UserRepository } from '../repositories/user_repository.js'

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
    return activities.map((activity) => {
      const serializedActivity = activity.serialize();
      serializedActivity.likesCount = activity.likes.length; // Append likes count
      return serializedActivity;
    });
  }
  

  async userActivities({ auth, params }: HttpContext) {
    const currentUser = auth.user!
    const targetUserId = Number.parseInt(params.id)
  
    if (currentUser.id === targetUserId) {
      const activities = await this.activityRepository.findUserActivitiesById(targetUserId)
      return activities.map((activity) => {
        const serializedActivity = activity.serialize();
        serializedActivity.likesCount = activity.likes.length; // Append likes count
        return serializedActivity;
      });
    }
  
    const targetUser = await User.findOrFail(targetUserId);
    if (await this.userRepository.isFriendsWith(currentUser, targetUser)) {
      const activities = await this.activityRepository.findUserActivitiesById(targetUserId)
      return activities.map((activity) => {
        const serializedActivity = activity.serialize();
        serializedActivity.likesCount = activity.likes.length; // Append likes count
        return serializedActivity;
      });
    } else {
      throw new Exception('Access Denied: User is not a friend or the user themself.', {
        status: 403,
      });
    }
  }
  
  async activityDetails({ auth, params }: HttpContext) {
    const user = auth.user!
    const activityId = Number.parseInt(params.id);
    const activity = await this.activityRepository.findActivityDetails(user.id, activityId);
  
    const serializedActivity = activity.serialize();
    serializedActivity.likesCount = activity.likes.length; // Append likes count
    return serializedActivity;
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
    return activity.serialize()
  }

  async like({ auth, request }: HttpContext) {
    const userId = auth.user!.id
    const { activityId } = await likeValidator.validate(request.all())

    await this.likesRepository.createLike(userId, activityId)
  }

  async unlike({ auth, request }: HttpContext) {
    const userId = auth.user!.id
    const { activityId } = await likeValidator.validate(request.all())

    await this.likesRepository.deleteLike(userId, activityId)
  }
}
