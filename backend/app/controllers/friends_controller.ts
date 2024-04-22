import Invite from '#models/invite'
import User from '#models/user'
import { searchFriendsValidator } from '#validators/friends_validator'
import { inject } from '@adonisjs/core'
import type { HttpContext } from '@adonisjs/core/http'
import { UserRepository } from '../repositories/user_repository.js'

/** Controller for managing user's friends */
@inject()
export default class FriendsController {
  constructor(protected userRepository: UserRepository) {}

  /**
   * GET `/friend`
   *
   * This method returns a list of friends for the authenticated user
   */
  async index({ auth }: HttpContext) {
    const user = auth.user!
    await user.load('friends')

    const invites = await Invite.query().where('receiverId', user.id).preload('sender')

    return {
      friends: user.friends.map((friend) => friend.serialize()),
      invites: invites.map((invite) => invite.sender.serialize()),
    }
  }

  /**
   * GET `/friend/search?query=someone`
   *
   * This method searches for users based on a query string
   */
  async search({ request, auth }: HttpContext) {
    const user = auth.user!
    const { query } = await searchFriendsValidator.validate(request.all())
    const results = await this.userRepository.searchUsers(query) // Assuming a static search method on the User model

    return { users: results.filter((v) => v.id !== user.id).map((v) => v.serialize()) }
  }

  /**
   * POST `/friend/invite`
   *
   * This method sends a friend invite from the authenticated user to another user
   */
  async invite({ request, auth }: HttpContext) {
    const user = auth.user!
    const recipient = await User.findOrFail(request.input('id'))
    const inviteResult = await this.userRepository.sendInvite(user, recipient)

    return { result: inviteResult }
  }

  /**
   * PUT `/friend/invite/:id/accept`
   *
   * This method allows a user to accept a friend invite
   */
  async accept({ request, auth }: HttpContext) {
    const user = auth.user!
    const senderId = request.param('id')

    const invite = await Invite.query()
      .where('senderId', senderId)
      .where('receiverId', user.id)
      .firstOrFail()

    await this.userRepository.acceptInvite(invite)
  }

  /**
   * PUT `/friend/invite/:id/accept`
   *
   * This method allows a user to deny a friend invite
   */
  async deny({ request, auth }: HttpContext) {
    const user = auth.user!
    const senderId = request.param('id')

    const invite = await Invite.query()
      .where('senderId', senderId)
      .where('receiverId', user.id)
      .firstOrFail()

    await this.userRepository.denyInvite(invite)
  }

  /**
   * POST `/friend/remove/:id`
   *
   * This method allows a user to remove a friendship
   */
  async remove({ request, auth }: HttpContext) {
    const user = auth.user!
    const target = request.param('id')
    const targetUser = await User.findOrFail(target)

    await this.userRepository.removeFriendship(user, targetUser)
  }
}
