class CreateBalances < ActiveRecord::Migration
  def change
    create_table :balances do |t|
      t.string  :block
      t.float   :amount
      t.float   :buy_price
      t.float   :sell_price

      t.timestamps null: false
    end
  end
end
