class AllowChangeColumnNull < ActiveRecord::Migration
  def change
    change_column(:test_tables, :id, :string)
  end
end