class RenameColumnTestTable < ActiveRecord::Migration
  def change
    rename_column(:test_tables, :id)
  end
end