import { inject } from '@adonisjs/core'
import { LevelRepository } from '../repositories/level_repository.js'

/** Controller for getting the point requirements of levels from the database */
@inject()
export default class LevelsController {
  constructor(protected readonly _levelRepository: LevelRepository) {}

  /** GET `/levels`
   * Returns all possible levels
   */
  async getLevels() {
    const levels = await this._levelRepository.getLevels()
    return levels.map((v) => v.serialize())
  }
}
