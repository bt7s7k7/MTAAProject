import logger from '@adonisjs/core/services/logger'
import { App, applicationDefault, getApps, initializeApp } from 'firebase-admin/app'
import { Messaging, getMessaging } from 'firebase-admin/messaging'

export class FirebaseService {
  protected _app: App | null = null
  async getApp() {
    if (this._app !== null) {
      return this._app
    }

    const existing = getApps()
    if (existing.length > 0) {
      logger.warn('Using firebase app from previous session')
      this._app = existing[0]
      return this._app
    }

    this._app = initializeApp({
      credential: applicationDefault(),
    })
    logger.info('Initialized firebase application')
    return this._app
  }

  protected _messaging: Messaging | null = null
  async getMessaging() {
    if (this._messaging !== null) return this._messaging
    return (this._messaging = getMessaging(await this.getApp()))
  }
}
