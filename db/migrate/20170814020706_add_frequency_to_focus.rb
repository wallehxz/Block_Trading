class AddFrequencyToFocus < ActiveRecord::Migration
  def change
    add_column :focus_blocks, :frequency, :integer, default:0
  end
end
