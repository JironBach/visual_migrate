class CreateCds < ActiveRecord::Migration
  def change
    create_table(:cds) do |t|
      t.timestamps
      t.string(:chstr, :default => "chstr", :null => (false))
      t.float(:chfloat, :limit => 10, :default => 0.0, :null => (false), :precision => 5, :scale => 5)
    end
  end
end