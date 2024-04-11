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

    for (const [key, value] of Object.entries(data)) {
      if (value === '' || value === null) {
        continue
      }

      const original = user[key as keyof typeof user]
      if (original !== value) {
        void ((user as any)[key] = value)
      }
    }

    await user.save()

    return user.serialize()
  }

  // POST /user/photo
  // Handles profile picture upload
  async uploadPhoto({ auth, request }: HttpContext) {
    const user = auth.user!
    const photo = request.file('photo', { size: '2mb' }) // Validate file size

    if (photo) {
      await photo.move(`./uploads/users/${user.id}`, {
        name: `profile.${photo.extname}`, // Save with a custom name
      })

      // Update user's profile picture URL/path in the database
      // Assuming there's a field `profile_photo` in the User model
      user.icon = `uploads/users/${user.id}/profile.${photo.extname}`
      await user.save()
    }

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
