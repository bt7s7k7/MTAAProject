/*
|--------------------------------------------------------------------------
| Routes file
|--------------------------------------------------------------------------
|
| The routes file is used for defining the HTTP routes.
|
*/

import app from '@adonisjs/core/services/app'
import router from '@adonisjs/core/services/router'
import { normalize, sep } from 'node:path'
import { middleware } from './kernel.js'
const FriendsController = () => import('#controllers/friends_controller')
const UserController = () => import('#controllers/users_controller')
const AuthController = () => import('#controllers/auth_controller')

router.get('/', async () => {
  return {
    hello: 'world',
  }
})

const PATH_TRAVERSAL_REGEX = /(?:^|[\\/])\.\.(?:[\\/]|$)/

router.get('/uploads/icons/default', ({ response }) => {
  return response.download(app.makePath('default_icon.png'))
})

router.get('/uploads/*', ({ request, response }) => {
  const filePath = request.param('*').join(sep)
  const normalizedPath = normalize(filePath)

  if (PATH_TRAVERSAL_REGEX.test(normalizedPath)) {
    return response.badRequest('Malformed path')
  }

  const absolutePath = app.makePath('uploads', normalizedPath)
  console.log(absolutePath)
  return response.download(absolutePath)
})

router
  .group(() => {
    router.post('/login', [AuthController, 'login'])
    router.post('/register', [AuthController, 'register'])
    router.get('/me', [AuthController, 'me']).use(middleware.auth())
  })
  .prefix('auth')

router
  .group(() => {
    router.get('/', [UserController, 'index'])
    router.post('/', [UserController, 'update'])
    router.post('/photo', [UserController, 'uploadPhoto'])
    router.post('/:id', [UserController, 'show'])
  })
  .prefix('user')
  .use(middleware.auth())

router
  .group(() => {
    router.get('/', [FriendsController, 'index'])
    router.get('/search', [FriendsController, 'search'])
    router.post('/invite', [FriendsController, 'invite'])
    router.post('/invite/:id/accept', [FriendsController, 'accept'])
    router.post('/invite/:id/deny', [FriendsController, 'deny'])
  })
  .prefix('friend')
  .use(middleware.auth())
