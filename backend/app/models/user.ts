import { withAuthFinder } from '@adonisjs/auth'
import { DbAccessTokensProvider } from '@adonisjs/auth/access_tokens'
import { compose } from '@adonisjs/core/helpers'
import hash from '@adonisjs/core/services/hash'
import { BaseModel, column, hasOne, manyToMany } from '@adonisjs/lucid/orm'
import { type HasOne, type ManyToMany } from '@adonisjs/lucid/types/relations'
import { DateTime } from 'luxon'
import Level from './level.js'

const AuthFinder = withAuthFinder(() => hash.use('scrypt'), {
  uids: ['email'],
  passwordColumnName: 'password',
})

export default class User extends compose(BaseModel, AuthFinder) {
  @column({ isPrimary: true })
  declare id: number

  @column()
  declare fullName: string | null

  @column()
  declare email: string

  @column({ serialize: () => null })
  declare password: string

  @column.dateTime({ autoCreate: true })
  declare createdAt: DateTime

  @column.dateTime({ autoCreate: true, autoUpdate: true })
  declare updatedAt: DateTime | null

  @column({ serializeAs: null })
  declare levelId: number

  @hasOne(() => Level, { foreignKey: 'levelId' })
  declare level: HasOne<typeof Level>

  @column()
  declare icon: string

  @manyToMany(() => User, {
    localKey: 'id',
    pivotForeignKey: 'user_id',
    relatedKey: 'id',
    pivotRelatedForeignKey: 'friend_id',
    pivotTable: 'users_friends',
  })
  declare friends: ManyToMany<typeof User>

  static accessTokens = DbAccessTokensProvider.forModel(User)
}
