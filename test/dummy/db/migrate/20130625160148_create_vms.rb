class CreateVms < ActiveRecord::Migration
  def change
    create_table(:vms) do |t|
      t.timestamps
      t.string(:vmstr, :default => "vmstr", :null => (false))
    end
  end
end