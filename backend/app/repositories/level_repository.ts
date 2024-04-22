import Level from '#models/level'

/** Class for getting level information */
export class LevelRepository {
  /** Levels are cached from the database, so they do not have to be constantly queried. */
  protected _levelsCache: Level[] | null = null

  /** Calculates what level should a user be based on their points count */
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

  /** Gets a list of all possible levels */
  async getLevels() {
    if (this._levelsCache === null) {
      this._levelsCache = await Level.query().orderBy('pointsRequired', 'asc')
    }

    return this._levelsCache
  }
}
