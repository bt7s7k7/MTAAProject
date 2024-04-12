import User from '#models/user'
import logger from '@adonisjs/core/services/logger'
import { Server } from 'socket.io'

export interface NotifyOptions {
  /** Type of the entity that is changed */
  type: string
  /** ID of the changed entity */
  id: number
  /** New value of the entity, leave as `null` to delete */
  value: object | null
}

export class UserEventRouter {
  constructor(public io: Server) {
    io.on('connect', (socket) => {
      const user = socket.handshake.auth as User
      logger.info('Connected ' + user.email)

      socket.join('user:' + user.id)
      socket.join('friends:' + user.id)
      user.load('friends').then(() => {
        for (const friend of user.friends) {
          socket.join('friends:' + friend.id)
        }
      })

      socket.emit('debug', user.email)

      socket.on('disconnect', () => {
        logger.info('Disconnected ' + user.email)
      })
    })
  }

  protected async _updateFriendFor(user: number, friend: number, change: 'added' | 'removed') {
    const sockets = await this.io.in('user:' + user).fetchSockets()
    for (const socket of sockets) {
      if (change === 'added') {
        socket.join('friends:' + friend)
      } else {
        socket.leave('friends:' + friend)
      }
    }
  }

  async updateFriendshipState(user1: number, user2: number, change: 'added' | 'removed') {
    await Promise.all([
      this._updateFriendFor(user1, user2, change),
      this._updateFriendFor(user2, user1, change),
    ])
  }

  notifyUser(userId: number, options: NotifyOptions) {
    this.notify('user:' + userId, options)
  }

  notifyUserAndFriends(userId: number, options: NotifyOptions) {
    this.notify('friends:' + userId, options)
  }

  notify(room: string, options: NotifyOptions) {
    this.io.in(room).emit('update', options)
  }
}
