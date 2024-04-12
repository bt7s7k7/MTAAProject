import authConfig from '#config/auth'
import { UserEventRouter } from '#services/user_event_router'
import { HttpContext } from '@adonisjs/core/http'
import logger from '@adonisjs/core/services/logger'
import { ApplicationService } from '@adonisjs/core/types'
import { ContainerProviderContract } from '@adonisjs/core/types/app'
import { Server } from 'socket.io'

export default class WSProvider implements ContainerProviderContract {
  constructor(public app: ApplicationService) {}

  async ready() {
    const httpServerService = await this.app.container.make('server')
    const httpServer = httpServerService.getNodeServer()
    const authResolver = await authConfig.resolver(this.app)
    const io = new Server(httpServer, {
      cors: {
        origin: '*',
        methods: ['GET', 'POST'],
      },
    })

    io.use(async (socket, next) => {
      const token = socket.handshake.auth.token

      const auth = authResolver.guards.api({
        request: {
          header: () => `Bearer ${token}`,
        },
      } as unknown as HttpContext)

      try {
        const user = await auth.authenticate()
        socket.handshake.auth = user

        next()
      } catch (err) {
        next(err)
      }
    })

    this.app.container.bindValue(UserEventRouter, new UserEventRouter(io))
    logger.info('Running WS server ' + JSON.stringify(httpServer!.address()))
  }
}
