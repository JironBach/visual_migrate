class CreateSakes < ActiveRecord::Migration
  def change
    create_table(:sakes) do |t|
      t.string(:commentator, :limit => 16, :default => "", :null => (false))
      t.string(:comment, :limit => 128, :default => "", :null => (false))
    end
  end
end