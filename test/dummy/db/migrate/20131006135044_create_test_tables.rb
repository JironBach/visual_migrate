class CreateTestTables < ActiveRecord::Migration
  def change
    create_table(:test_tables, :primary_key => "id", :options => "", :force => (false)) do |t|
      t.timestamps
      t.string(:title, :limit => 64, :default => "abc", :null => (false))
      t.text(:contents)
    end
  end
end