class IndexTest < ActiveRecord::Migration
  def up
    add_index(:test_tables, [:title, :test_int], :name => "test_index", :unique => (false))
  end
  
  def down
    remove_index(:test_tables, :name => "test_index")
  end
end