import { BaseModel, column, hasOne } from '@adonisjs/lucid/orm'
import type { HasOne } from '@adonisjs/lucid/types/relations'
import { DateTime } from 'luxon'

/** Model for `levels` table */
export default class Level extends BaseModel {
  @column({ isPrimary: true })
  declare id: number

  @column()
  declare name: string

  @column.dateTime({ autoCreate: true })
  declare createdAt: DateTime

  @column.dateTime({ autoCreate: true, autoUpdate: true })
  declare updatedAt: DateTime

  @column()
  declare pointsRequired: number

  @column({ serializeAs: null })
  declare nextId: number | null

  @hasOne(() => Level, { foreignKey: 'nextId' })
  declare next: HasOne<typeof Level>
}
