import Invite from '#models/invite'
import User from '#models/user'
import { inject } from '@adonisjs/core'
import { Exception } from '@adonisjs/core/exceptions'
import type { HttpContext } from '@adonisjs/core/http'
import { UserRepository } from '../repositories/user_repository.js'

@inject()
export default class FriendsController {
  constructor(protected userRepository: UserRepository) {}

  /**
   * GET /friends
   *
   * This method returns a list of friends for the authenticated user
   */
  async index({ auth }: HttpContext) {
    const user = auth.user!
    await user.preload('friends')

    return user.friends.map((friend) => friend.serialize())
  }

  /**
   * GET /friends/search?query=someone
   *
   * This method searches for users based on a query string
   */
  async search({ request }: HttpContext) {
    const query = request.input('query')
    const results = await this.userRepository.searchUsers(query) // Assuming a static search method on the User model

    return results.map((user) => user.serialize())
  }

  /**
   * POST /friends/invite
   *
   * This method sends a friend invite from the authenticated user to another user
   */
  async invite({ request, auth }: HttpContext) {
    const user = auth.user!
    const recipient = await User.findOrFail(request.input('id'))
    const invite = await this.userRepository.sendInvite(user, recipient) // Assuming a method to send a friend invite

    return invite.serialize()
  }

  /**
   * POST /friends/invite/:id/accept
   *
   * This method allows a user to accept a friend invite
   */
  async accept({ request, auth }: HttpContext) {
    const invite = await Invite.findOrFail(request.param('id'))
    if (invite.friendId !== auth.user!.id) throw new Exception('invalid_invite', { status: 400 })
    await this.userRepository.acceptInvite(invite) // Assuming a method to accept a friend invite
  }

  /**
   * POST /friends/invite/:id/accept
   *
   * This method allows a user to deny a friend invite
   */
  async deny({ request, auth }: HttpContext) {
    const invite = await Invite.findOrFail(request.param('id'))
    if (invite.friendId !== auth.user!.id) throw new Exception('invalid_invite', { status: 400 })
    await this.userRepository.denyInvite(invite) // Assuming a method to deny a friend invite
  }
}
