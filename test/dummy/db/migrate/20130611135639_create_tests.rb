class CreateTests < ActiveRecord::Migration
  def change
    create_table(:tests) do |t|
      t.timestamps
      t.string(str(:default => "str_dev"))
      t.integer(num, :limit => 51, :default => 2, :null => (false), :precision => 3, :scale => 4)
    end
  end
end