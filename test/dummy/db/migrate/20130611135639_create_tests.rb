class CreateTests < ActiveRecord::Migration
  def change
    create_table :tests do |t|
      t.timestamps

      t.string :str, :default => "str_def"
    end
  end
end
