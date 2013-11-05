class RemoveTimestampsTest < ActiveRecord::Migration
  def up
    remove_timestamps(:test_tables)
  end
  
  def down
    add_timestamps(:test_tables)
  end
end