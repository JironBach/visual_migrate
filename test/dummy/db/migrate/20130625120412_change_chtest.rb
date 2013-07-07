class ChangeChtest < ActiveRecord::Migration
  def up
    change_table(:chtests) { |t| t.rename(chstr, ch_str) }
  end
  
  def change
    # do nothing
  end
end