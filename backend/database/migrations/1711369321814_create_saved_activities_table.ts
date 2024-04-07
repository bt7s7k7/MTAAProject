import { BaseSchema } from '@adonisjs/lucid/schema'

export default class UserActivities extends BaseSchema {
  protected tableName = 'activities'

  async up() {
    this.schema.createTable(this.tableName, (table) => {
      table.increments('id')
      table.integer('user_id').unsigned().references('id').inTable('users').onDelete('CASCADE')
      // The existing 'activity_name' and 'points' columns remain unchanged
      table.string('activity_name').notNullable()
      table.integer('points').unsigned()
      // New columns based on your requirements
      table.integer('distance').unsigned().notNullable() // Assuming distance is stored as an integer (e.g., meters)
      table.integer('steps').unsigned().notNullable() // Assuming steps are stored as an integer
      table.integer('duration').unsigned().notNullable() // Assuming duration is stored in seconds as an integer
      table.text('path').nullable() // Storing the path as text, assuming it's a serialized form or a reference
      table.timestamp('created_at').notNullable()
      table.timestamp('updated_at').notNullable()
    })
  }

  async down() {
    this.schema.dropTable(this.tableName)
  }
}
