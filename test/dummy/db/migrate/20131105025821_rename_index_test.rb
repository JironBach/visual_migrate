class RenameIndexTest < ActiveRecord::Migration
  def change
    rename_index(:test_tables, "test_index", "idx")
  end
end