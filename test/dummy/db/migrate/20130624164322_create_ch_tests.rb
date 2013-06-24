class CreateChTests < ActiveRecord::Migration
  def change
    create_table(:chtests) do |t|
      t.string(:chstr, :default => "chstr", :null => (false))
      t.timestamps
    end
  end
end