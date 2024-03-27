import Level from '#models/level'

export class LevelRepository {
  async getLevelByPoints(points: number) {
    const level = await Level.query()
      .orderBy('pointsRequired', 'desc')
      .where('pointsRequired', '<=', points)
      .first()

    return level
  }
}
