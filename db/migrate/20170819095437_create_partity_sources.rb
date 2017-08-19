class CreatePartitySources < ActiveRecord::Migration
  def change
    create_table :partity_sources do |t|
      t.integer :block_parity_id
      t.string  :platform
      t.string  :ticker_url
      t.string  :css_anchor
      t.float   :last_price
      t.timestamps null: false
    end
  end
end
