import { App, applicationDefault, initializeApp } from 'firebase-admin/app'
import { Messaging, getMessaging } from 'firebase-admin/messaging'

export class FirebaseService {
  protected _app: App | null = null
  async getApp() {
    return (this._app ??= initializeApp({
      credential: applicationDefault(),
    }))
  }

  protected _messaging: Messaging | null = null
  async getMessaging() {
    return (this._messaging ??= getMessaging(await this.getApp()))
  }
}
