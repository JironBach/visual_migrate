class ChangeCh22 < ActiveRecord::Migration
  def change
    change_table(:ch2s) { |t| t.rename(:ch_str, :chstr) }
  end
end