import { BaseSchema } from '@adonisjs/lucid/schema'

export default class UserFriends extends BaseSchema {
  protected tableName = 'users_friends'

  async up() {
    this.schema.createTable(this.tableName, (table) => {
      table.increments('id')
      table.integer('user_id').unsigned().references('id').inTable('users').onDelete('CASCADE')
      table.integer('friend_id').unsigned().references('id').inTable('users').onDelete('CASCADE')
      table.unique(['user_id', 'friend_id']) // Zabezpečí, že každý pár priateľov je jedinečný
    })
  }

  async down() {
    this.schema.dropTable(this.tableName)
  }
}
