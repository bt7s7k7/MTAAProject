import Level from '#models/level'

export class LevelRepository {
  protected _levelsCache: Level[] | null = null

  async getLevelByPoints(points: number) {
    const levels = await this.getLevels()
    const nextLevel = levels.findIndex((v) => v.pointsRequired > points)
    const level =
      nextLevel === -1
        ? levels[levels.length - 1]
        : nextLevel === 0
          ? levels[0]
          : levels[nextLevel - 1]

    return level
  }

  async getLevels() {
    if (this._levelsCache === null) {
      this._levelsCache = await Level.query().orderBy('pointsRequired', 'asc')
    }

    return this._levelsCache
  }
}
