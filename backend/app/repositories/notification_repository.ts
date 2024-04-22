import User from '#models/user'
import { FirebaseService } from '#services/firebase_service'
import { inject } from '@adonisjs/core'
import logger from '@adonisjs/core/services/logger'

/** Defines notification data sent to the client device */
export interface Notification {
  title: string
  body: string
  route: string
}

/** Class for sending notifications to client devices */
@inject()
export class NotificationRepository {
  constructor(protected firebase: FirebaseService) {}

  /** Saves or removes a FCM token from a user */
  async setNotificationToken(user: User, token: string | null) {
    user.pushToken = token
    await user.save()
  }

  /** Sends a notification to a user and their friends */
  async sendNotificationUserFriends(user: User, notification: Notification) {
    await user.load('friends')
    const tokens = user.friends.map((v) => v.pushToken).filter((v): v is string => v !== null)

    await this._sendNotification(tokens, notification)
  }

  /** Sends a notification to a user */
  async sendNotificationUser(user: User, notification: Notification) {
    if (user.pushToken === null) return
    this._sendNotification([user.pushToken], notification)
  }

  /** Sends a notification based on FCM token list, used internally in {@link sendNotificationUser} and {@link sendNotificationUserFriends}. */
  protected async _sendNotification(tokens: string[], notification: Notification) {
    if (tokens.length === 0) return

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
