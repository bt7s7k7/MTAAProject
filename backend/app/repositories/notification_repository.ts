import User from '#models/user'
import { FirebaseService } from '#services/firebase_service'
import { inject } from '@adonisjs/core'

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

  async sendNotificationUserAndFriends(user: User, notification: Notification) {
    await user.load('friends')
    const tokens = [user]
      .concat(user.friends)
      .map((v) => v.pushToken)
      .filter((v): v is string => v !== null)

    await this._sendNotification(tokens, notification)
  }

  async sendNotificationUser(user: User, notification: Notification) {
    if (user.pushToken === null) return
    this._sendNotification([user.pushToken], notification)
  }

  protected async _sendNotification(tokens: string[], notification: Notification) {
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
