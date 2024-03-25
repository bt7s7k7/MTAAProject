import Level from '#models/level'
import { BaseSeeder } from '@adonisjs/lucid/seeders'

export default class extends BaseSeeder {
  async run() {
    const levels = await Level.updateOrCreateMany('name', [
      { name: 'bronze', pointsRequired: 100 },
      { name: 'silver', pointsRequired: 1000 },
      { name: 'gold', pointsRequired: 25000 },
    ])

    for (let i = 1; i < levels.length; i++) {
      const prev = levels[i - 1]
      const next = levels[i]
      prev.nextId = next.id
    }

    await Promise.all(levels.map((v) => v.save()))
  }
}
