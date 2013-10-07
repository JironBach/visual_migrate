class CreateTestTables < ActiveRecord::Migration
  def change
    create_table(:test_tables) do |t|
      t.timestamps
      t.string(:commentator, :limit => 64, :null => (false))
      t.text(:comment, :null => (false))
    end
  end
end