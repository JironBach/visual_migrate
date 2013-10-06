class CreateVisualMigrateSchemaMigrations < ActiveRecord::Migration
  def change
    create_table :visual_migrate_schema_migrations do |t|
      t.string(:version, :limit => 255, :null => (false))
    end
  end
end
