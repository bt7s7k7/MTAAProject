import { DateTime } from 'luxon'
import { BaseModel, column, belongsTo } from '@adonisjs/lucid/orm'
import User from './user.js'
import Activity from './activity.js'
import type { BelongsTo } from '@adonisjs/lucid/types/relations'

export default class Like extends BaseModel {
  @column({ isPrimary: true })
  id!: number // Non-null assertion here

  @column()
  userId!: number // Non-null assertion here

  @column()
  activityId!: number // Non-null assertion here

  @column.dateTime({ autoCreate: true })
  createdAt!: DateTime // Non-null assertion here

  @column.dateTime({ autoCreate: true, autoUpdate: true })
  updatedAt!: DateTime // Non-null assertion here

  @belongsTo(() => User)
  user!: BelongsTo<typeof User> // Non-null assertion here

  @belongsTo(() => Activity)
  activity!: BelongsTo<typeof Activity> // Non-null assertion here

  serialize() {
    return {
      id: this.id,
      userId: this.userId,
      activityId: this.activityId,
      createdAt: this.createdAt.toISO(),
      updatedAt: this.updatedAt.toISO(),
    }
  }
}
