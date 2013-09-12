class AddColumns < ActiveRecord::Migration
  def change
    drop_table(:vmtests)
  end
end