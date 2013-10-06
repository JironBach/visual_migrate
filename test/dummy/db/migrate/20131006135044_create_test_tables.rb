class CreateTestTables < ActiveRecord::Migration
  def change
    create_table :test_tables do |t|

      t.timestamps
    end
  end
end
