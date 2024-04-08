import { DateTime } from 'luxon'
import { BaseModel, column, belongsTo } from '@adonisjs/lucid/orm'
import User from './user.js'
import Activity from './activity.js'
import type { BelongsTo } from '@adonisjs/lucid/types/relations'


export default class Like extends BaseModel {
    @column({ isPrimary: true })
    public id!: number // Non-null assertion here
  
    @column()
    public userId!: number // Non-null assertion here
  
    @column()
    public activityId!: number // Non-null assertion here
  
    @column.dateTime({ autoCreate: true })
    public createdAt!: DateTime // Non-null assertion here
  
    @column.dateTime({ autoCreate: true, autoUpdate: true })
    public updatedAt!: DateTime // Non-null assertion here
  
    @belongsTo(() => User)
    public user!: BelongsTo<typeof User> // Non-null assertion here
  
    @belongsTo(() => Activity)
    public activity!: BelongsTo<typeof Activity> // Non-null assertion here

    public serialize() {
        return {
          id: this.id,
          userId: this.userId,
          activityId: this.activityId,
          createdAt: this.createdAt.toISO(),
          updatedAt: this.updatedAt.toISO(),
        }
      }

}
