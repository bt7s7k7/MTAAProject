import User from '#models/user'
import { FirebaseService } from '#services/firebase_service'
import { inject } from '@adonisjs/core'
import logger from '@adonisjs/core/services/logger'

export interface Notification {
  title: string
  body: string
  route: string
}

@inject()
export class NotificationRepository {
  constructor(protected firebase: FirebaseService) {}

  async setNotificationToken(user: User, token: string | null) {
    user.pushToken = token
    await user.save()
  }

  async sendNotificationUserFriends(user: User, notification: Notification) {
    await user.load('friends')
    const tokens = user.friends.map((v) => v.pushToken).filter((v): v is string => v !== null)

    await this._sendNotification(tokens, notification)
  }

  async sendNotificationUser(user: User, notification: Notification) {
    if (user.pushToken === null) return
    this._sendNotification([user.pushToken], notification)
  }

  protected async _sendNotification(tokens: string[], notification: Notification) {
    logger.info({ tokens, ...notification }, 'Sending notifications')

    const messaging = await this.firebase.getMessaging()
    messaging.sendEachForMulticast({
      tokens,
      notification: {
        title: notification.title,
        body: notification.body,
      },
      data: { route: notification.route },
    })
  }
}
