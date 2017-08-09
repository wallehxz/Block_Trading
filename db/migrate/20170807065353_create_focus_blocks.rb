class CreateFocusBlocks < ActiveRecord::Migration
  def change
    create_table :focus_blocks do |t|
      t.integer :block_id
      t.float   :buy_amount
      t.float   :total_price
      t.float   :sell_weights
      t.float   :sell_amplitude
      t.boolean :activation
      t.timestamps null: false
    end
  end
end
