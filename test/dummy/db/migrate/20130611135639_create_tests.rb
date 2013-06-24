class CreateTests < ActiveRecord::Migration
  def change
    create_table(:chtests) { |t| t.timestamps }
  end
end