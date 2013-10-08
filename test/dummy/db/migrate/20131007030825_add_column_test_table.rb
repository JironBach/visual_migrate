class AddColumnTestTable < ActiveRecord::Migration
  def change
    rename_table(:test_tables, :testes_tables)
  end
end
