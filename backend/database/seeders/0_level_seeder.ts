import Level from '#models/level'
import { BaseSeeder } from '@adonisjs/lucid/seeders'

export default class extends BaseSeeder {
  async run() {
    const levels = await Level.updateOrCreateMany('name', [
      { name: 'bronze', pointsRequired: 5000 },
      { name: 'silver', pointsRequired: 15000 },
      { name: 'gold', pointsRequired: 40000 },
      { name: 'platinum', pointsRequired: 80000 },
    ])

    for (let i = 1; i < levels.length; i++) {
      const prev = levels[i - 1]
      const next = levels[i]
      prev.nextId = next.id
    }

    await Promise.all(levels.map((v) => v.save()))
  }
}
