// import type { HttpContext } from '@adonisjs/core/http'

import { inject } from '@adonisjs/core'
import { LevelRepository } from '../repositories/level_repository.js'

@inject()
export default class LevelsController {
  constructor(protected readonly _levelRepository: LevelRepository) {}

  async getLevels() {
    const levels = await this._levelRepository.getLevels()
    return levels.map((v) => v.serialize())
  }
}
