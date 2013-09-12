class ChangeTests < ActiveRecord::Migration
  def change
    drop_table(:ch2s)
  end
end