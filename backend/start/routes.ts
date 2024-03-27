/*
|--------------------------------------------------------------------------
| Routes file
|--------------------------------------------------------------------------
|
| The routes file is used for defining the HTTP routes.
|
*/

import router from '@adonisjs/core/services/router'
import { middleware } from './kernel.js'
const FriendsController = () => import('#controllers/friends_controller')
const UserController = () => import('#controllers/users_controller')
const AuthController = () => import('#controllers/auth_controller')

router.get('/', async () => {
  return {
    hello: 'world',
  }
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
