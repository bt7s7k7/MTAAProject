import { BaseModel, belongsTo, column } from '@adonisjs/lucid/orm'
import type { BelongsTo } from '@adonisjs/lucid/types/relations'
import { DateTime } from 'luxon'
import User from './user.js'

export default class Activity extends BaseModel {
  @column({ isPrimary: true })
  declare id: number

  @column.dateTime({ autoCreate: true })
  declare createdAt: DateTime

  @column.dateTime({ autoCreate: true, autoUpdate: true })
  declare updatedAt: DateTime

  // Pridané stĺpce podľa špecifikácie
  @column()
  declare userId: number

  @column()
  declare activityName: string

  @column()
  declare points: number

  @column()
  declare distance: number

  @column()
  declare steps: number

  @column()
  declare duration: number

  @column()
  declare path: string | null

  // Definícia vzťahu s modelom User
  @belongsTo(() => User, {
    foreignKey: 'userId',
  })
  declare user: BelongsTo<typeof User>
}
