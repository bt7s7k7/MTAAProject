import User from '#models/user'
import { loginValidator, registerValidator } from '#validators/auth_validator'
import { Exception } from '@adonisjs/core/exceptions'
import { HttpContext } from '@adonisjs/core/http'

export default class AuthController {
  async login({ request }: HttpContext) {
    const { email, password } = await loginValidator.validate(request.all())

    const user = await User.verifyCredentials(email, password)
    const token = await User.accessTokens.create(user)

    return {
      user: user.serialize(),
      token: token.value!.release(),
    }
  }

  async register({ request }: HttpContext) {
    const data = await registerValidator.validate(request.all())

    let user
    try {
      user = await User.create(data)
    } catch (err: any) {
      if (err.constraint === 'users_email_unique') {
        throw new Exception('email_in_use', { status: 400 })
      }

      throw err
    }

    const token = await User.accessTokens.create(user)

    return {
      user: user.serialize(),
      token: token.value!.release(),
    }
  }

  async me({ auth }: HttpContext) {
    const user = auth.user!

    return user.serialize()
  }
}
