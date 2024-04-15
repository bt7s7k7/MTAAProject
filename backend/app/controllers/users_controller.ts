import User from '#models/user'
import { userUpdateValidator } from '#validators/user_validator'
import { inject } from '@adonisjs/core'
import { Exception } from '@adonisjs/core/exceptions'
import type { HttpContext } from '@adonisjs/core/http'
import { UserRepository } from '../repositories/user_repository.js'

@inject()
export default class UserController {
  constructor(protected userRepository: UserRepository) {}

  // GET /user
  // Returns details of the logged-in user
  async index({ auth }: HttpContext) {
    const user = auth.user!
    return user.serialize()
  }

  // POST /user
  // Updates user data
  async update({ auth, request }: HttpContext) {
    const user = auth.user!
    const data = await userUpdateValidator.validate(request.all())

    this.userRepository.updateUser(user, data)

    return user.serialize()
  }

  // POST /user/photo
  // Handles profile picture upload
  async uploadPhoto({ auth, request }: HttpContext) {
    const user = auth.user!
    const photo = request.file('photo', { size: '2mb' }) // Validate file size
    if (!photo) throw new Exception('Missing photo file', { status: 400 })

    await this.userRepository.uploadIcon(user, photo)

    return user.serialize()
  }

  // GET /user/:id
  // Returns details of a selected user, if they are friends
  async show({ auth, params }: HttpContext) {
    const user = auth.user!
    const targetUserId = params['id']
    const targetUser = await User.findOrFail(targetUserId)

    if (!(await this.userRepository.isFriendsWith(user, targetUser))) {
      throw new Exception('not_friend', { status: 400 })
    }

    return targetUser.serialize()
  }
}
