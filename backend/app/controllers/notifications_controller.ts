import { notificationValidator } from '#validators/notification_validator'
import { inject } from '@adonisjs/core'
import { HttpContext } from '@adonisjs/core/http'
import { NotificationRepository } from '../repositories/notification_repository.js'

@inject()
export default class NotificationsController {
  constructor(protected notificationRepository: NotificationRepository) {}

  async enableNotifications({ auth, request }: HttpContext) {
    const { pushToken } = await notificationValidator.validate(request.all())
    await this.notificationRepository.setNotificationToken(auth.user!, pushToken)
  }

  async disableNotifications({ auth }: HttpContext) {
    await this.notificationRepository.setNotificationToken(auth.user!, null)
  }
}
