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

import { dirname, join, normalize, sep } from 'node:path'
import { fileURLToPath } from 'node:url'
import { middleware } from './kernel.js'
const LevelsController = () => import('#controllers/levels_controller')
const FriendsController = () => import('#controllers/friends_controller')
const UserController = () => import('#controllers/users_controller')
const AuthController = () => import('#controllers/auth_controller')
const ActivityController = () => import('#controllers/activities_controller')
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
  return response.download(absolutePath)
})

router.get('/quick-front/*', ({ request, response }) => {
  const filePath = request.param('*').join(sep)
  const normalizedPath = normalize(filePath)

  if (PATH_TRAVERSAL_REGEX.test(normalizedPath)) {
    return response.badRequest('Malformed path')
  }

  const assetsBase = fileURLToPath(dirname(import.meta.resolve('quick-front')))
  const absolutePath = join(assetsBase, normalizedPath)
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
    router.put('/', [UserController, 'update'])
    router.put('/photo', [UserController, 'uploadPhoto'])    
    router.post('/:id', [UserController, 'show'])
  })
  .prefix('user')
  .use(middleware.auth())

router
  .group(() => {
    router.get('/', [FriendsController, 'index'])
    router.get('/search', [FriendsController, 'search'])
    router.post('/invite', [FriendsController, 'invite'])
    router.put('/invite/:id/accept', [FriendsController, 'accept'])
    router.put('/invite/:id/deny', [FriendsController, 'deny'])
    router.post('/remove/:id', [FriendsController, 'remove'])
  })
  .prefix('friend')
  .use(middleware.auth())

router
  .group(() => {
    router.get('/', [ActivityController, 'index'])
    router.get('/user/:id', [ActivityController, 'userActivities'])
    router.get('/:id', [ActivityController, 'activityDetails'])
    router.post('/', [ActivityController, 'store'])
    router.delete('/:id', [ActivityController, 'deleteActivity'])
    router.post('/like/:id', [ActivityController, 'like'])
    router.delete('/like/:id', [ActivityController, 'unlike'])
  })
  .prefix('activity')
  .use(middleware.auth())

router.get('/levels', [LevelsController, 'getLevels'])
