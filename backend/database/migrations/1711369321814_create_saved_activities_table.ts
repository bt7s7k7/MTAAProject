import { BaseSchema } from '@adonisjs/lucid/schema'

export default class UserActivities extends BaseSchema {
  protected tableName = 'saved_activities'

  async up() {
    this.schema.createTable(this.tableName, (table) => {
      table.increments('id')
      table.integer('user_id').unsigned().references('id').inTable('users').onDelete('CASCADE')
      table.string('activity_name').notNullable()
      table.integer('points').unsigned()
      table.timestamp('created_at').notNullable()
    })
  }

  async down() {
    this.schema.dropTable(this.tableName)
  }
}
