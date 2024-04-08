// controllers/ActivityController.ts
import { HttpContext } from '@adonisjs/core/http'
import { activityValidator } from '#validators/activity_validator'
import { ActivityRepository } from '../repositories/activity_repository.js'
import { UserRepository } from '../repositories/user_repository.js'
import User from '#models/user';

import { inject } from '@adonisjs/core'
import { Exception } from '@adonisjs/core/exceptions';

// controllers/ActivityController.ts

@inject()
export default class ActivityController {
  private activityRepo: ActivityRepository
  private userRepository: UserRepository


  constructor(activityRepo: ActivityRepository, userRepository: UserRepository) {
    this.activityRepo = activityRepo
    this.userRepository = userRepository
  }

  async index({ auth }: HttpContext) {
    const user = auth.user!
    const activities = await this.activityRepo.findAllUserAndFriendsActivities(user.id)
    return activities.map(activity => activity.serialize())
  }
  

  async userActivities({ auth, params }: HttpContext) {
    const currentUser = auth.user!
    const targetUserId = parseInt(params.id)
  
    // Allow direct access if the target user ID is the same as the current user's ID
    if (currentUser.id === targetUserId) {
      const activities = await this.activityRepo.findUserActivitiesById(targetUserId)
      return activities.map((activity) => activity.serialize()) // Serialize the activities
    }
  
    // Fetch the target user
    const targetUser = await User.findOrFail(targetUserId)
  
    // Check if the currentUser and targetUser are friends
    if (await this.userRepository.isFriendsWith(currentUser, targetUser)) {
      const activities = await this.activityRepo.findUserActivitiesById(targetUserId)
      return activities.map((activity) => activity.serialize()) // Serialize the activities
    } else {
      // If not friends, return an appropriate response
      throw new Exception('Access Denied: User is not a friend or the user themself.', {status: 403})
    }
  }
  
  

  async activityDetails({ auth, params }: HttpContext) {
    const user = auth.user!
    const activity = await this.activityRepo.findActivityDetails(user.id, parseInt(params.id))
    return activity.serialize()
  }
  

  async store({ auth, request }: HttpContext) {
    const user = auth.user!
    if (!user) {
      return 'User is not authenticated' 
    }
  
    const validation = await activityValidator.validate(request.all())
    const activity = await this.activityRepo.storeActivity(validation, user.id)
    return activity.serialize()
  }
  
}
