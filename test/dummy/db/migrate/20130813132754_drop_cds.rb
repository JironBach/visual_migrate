class DropCds < ActiveRecord::Migration
  def change
    drop_table(:cds)
  end
end