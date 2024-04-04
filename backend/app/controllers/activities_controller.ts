// controllers/ActivityController.ts
import { HttpContext } from '@adonisjs/core/http'
import { activityValidator } from '#validators/activity_validator'
import { ActivityRepository } from '../repositories/activity_repository.js'
import { inject } from '@adonisjs/core'

// controllers/ActivityController.ts

@inject()
export default class ActivityController {
  private activityRepo: ActivityRepository

  constructor(activityRepo: ActivityRepository) {
    this.activityRepo = activityRepo
  }

  async index({ auth }: HttpContext) {
    const user = auth.user!
    return await this.activityRepo.findAllUserAndFriendsActivities(user.id)
  }

  async userActivities({ auth, params }: HttpContext) {
    const user = auth.user!
    return await this.activityRepo.findUserActivitiesById(parseInt(params.id))
  }

  async activityDetails({ auth, params }: HttpContext) {
    const user = auth.user!
    return await this.activityRepo.findActivityDetails(user.id, parseInt(params.id))
  }

  async store({ auth, request }: HttpContext) {
    const user = auth.user!
    if (!user) {
      return 'User is not authenticated' // Replace with actual error handling
    }

    const validation = await activityValidator.validate(request.all())
    return await this.activityRepo.storeActivity(validation, user.id)
  }
}
