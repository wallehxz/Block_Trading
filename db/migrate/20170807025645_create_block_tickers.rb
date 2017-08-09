class CreateBlockTickers < ActiveRecord::Migration
  def change
    create_table :block_tickers do |t|
      t.integer :block_id
      t.float   :last_price
      t.float   :buy_price
      t.float   :sell_price
      t.date    :that_date

      t.timestamps null: false
    end
  end
end
