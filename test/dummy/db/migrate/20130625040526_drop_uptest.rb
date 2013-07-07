class DropUptest < ActiveRecord::Migration
  def change
    drop_table(:uptest)
  end
end