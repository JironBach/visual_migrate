class AddColumnTestTable < ActiveRecord::Migration
  def up
    add_column(:test_tables, :test_str, :string, :limit => 16, :default => "xyz")
    add_column(:test_tables, :test_int, :integer, :default => 100)
    add_column(:test_tables, :test_float, :float, :limit => 12, :default => 3.14, :precision => 6, :scale => 3)
  end
  
  def down
    remove_column(:test_tables, :test_str)
    remove_column(:test_tables, :test_int)
    remove_column(:test_tables, :test_float)
  end
end