class ChangeCh23 < ActiveRecord::Migration
  def change
    change_table(:chtests) { |t| t.rename(:chstr, :ch_str) }
  end
end