class ChangeColumnTest < ActiveRecord::Migration
  def up
    change_column_default(:test_tables, :tmp_str, nil)
    change_column(:test_tables, :tmp_str, :text, :limit => 32, :null => (false))
  end
  
  def down
    change_column(:test_tables, :tmp_str, :string, :limit => 16, :default => "xyz", :null => (false))
  end
end