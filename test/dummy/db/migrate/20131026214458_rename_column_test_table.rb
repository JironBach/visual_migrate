class RenameColumnTestTable < ActiveRecord::Migration
  def change
    rename_column(:test_tables, :test_str, :tmp_str)
  end
end