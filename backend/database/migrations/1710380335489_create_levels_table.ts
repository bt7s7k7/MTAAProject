import { BaseSchema } from '@adonisjs/lucid/schema'

export default class Levels extends BaseSchema {
  protected tableName = 'levels'

  async up() {
    this.schema.createTable(this.tableName, (table) => {
      table.increments('id').primary()
      table.integer('points_required').notNullable()
      table
        .integer('next_id')
        .unsigned()
        .nullable()
        .references('id')
        .inTable('levels')
        .onDelete('SET NULL')
      table.text('name').notNullable()

      table.timestamp('created_at', { useTz: true }).notNullable()
      table.timestamp('updated_at', { useTz: true }).nullable()
    })
  }

  async down() {
    this.schema.dropTable(this.tableName)
  }
}
