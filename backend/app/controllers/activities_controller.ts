import type { HttpContext } from '@adonisjs/core/http'
import Activity from '#models/activity'
import { activityValidator } from '#validators/activity_validator'

export default class ActivityController {
  async index({ auth }: HttpContext) {
    const user = auth.user!
    return await Activity.query().where('userId', user.id)
  }

  async store({ auth, request }: HttpContext) {
    const user = auth.user!

    // Validácia dát použitím activityValidator
    const data = await activityValidator.validate(request.all())

    const activity = await user.related('activities').create(data)
    return activity
  }

  async show({ params }: HttpContext) {
    return await Activity.findOrFail(params.id)
  }

  async update({ request, params }: HttpContext) {
    const activity = await Activity.findOrFail(params.id)

    // Validácia dát použitím activityValidator
    const data = await activityValidator.validate(request.all())

    activity.merge(data)
    await activity.save()

    return activity
  }

  async destroy({ params }: HttpContext) {
    const activity = await Activity.findOrFail(params.id)
    await activity.delete()
    return { message: 'Activity deleted' }
  }
}
