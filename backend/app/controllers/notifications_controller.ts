import { notificationValidator } from '#validators/notification_validator'
import { inject } from '@adonisjs/core'
import { HttpContext } from '@adonisjs/core/http'
import { NotificationRepository } from '../repositories/notification_repository.js'

/** Controller for the client application to report notification settings and FCM tokens */
@inject()
export default class NotificationsController {
  constructor(protected notificationRepository: NotificationRepository) {}

  /** POST `/notifications`
   * Enables notifications for the user
   */
  async enableNotifications({ auth, request }: HttpContext) {
    const { pushToken } = await notificationValidator.validate(request.all())
    await this.notificationRepository.setNotificationToken(auth.user!, pushToken)
  }

  /** POST `/notifications`
   * Disables notifications for the user
   */
  async disableNotifications({ auth }: HttpContext) {
    await this.notificationRepository.setNotificationToken(auth.user!, null)
  }
}
