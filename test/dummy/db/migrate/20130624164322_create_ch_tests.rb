class CreateChTests < ActiveRecord::Migration
  def change
    create_table(:chtests, :primary_key => "vm", :options => "ENGINE=InnoDB DEFAULT CHARSET=utf8") do |t|
      t.string(:chstr, :default => "chstr", :null => (false))
      t.timestamps
    end
  end
end