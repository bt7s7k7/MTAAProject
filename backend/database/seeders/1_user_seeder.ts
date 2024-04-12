import User from '#models/user'
import { BaseSeeder } from '@adonisjs/lucid/seeders'
import { faker } from '@faker-js/faker'
import { LevelRepository } from '../../app/repositories/level_repository.js'

export default class extends BaseSeeder {
  async run() {
    faker.seed(0)

    // IoC kontajnery sa nedajú použiť v seedery
    const levelRepository = new LevelRepository()

    await User.updateOrCreateMany(
      'email',
      await Promise.all(
        faker.helpers.multiple(
          async () => {
            const points = faker.helpers.rangeToNumber({ min: 0, max: 100000 })
            const level = await levelRepository.getLevelByPoints(points)
            const name = faker.person.firstName()

            return {
              email: `${name.toLowerCase()}@example.com`,
              fullName: `${name} ${faker.person.lastName()}`,
              password: '12345',
              points,
              levelId: level?.id,
            }
          },
          { count: 50 }
        )
      )
    )
  }
}
