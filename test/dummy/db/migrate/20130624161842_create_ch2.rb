class CreateCh2 < ActiveRecord::Migration
  def change
    create_table(:ch2) do |t|
      t.timestamps
      t.string(:chstr, :default => "chstr", :null => (false))
    end
  end
end
