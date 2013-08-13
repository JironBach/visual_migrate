class ChangeCds < ActiveRecord::Migration
  def change
    rename_table(:tests, :vmtests)
  end
end