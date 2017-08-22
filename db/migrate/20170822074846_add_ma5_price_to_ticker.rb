class AddMa5PriceToTicker < ActiveRecord::Migration
  def change
    add_column :block_tickers, :ma5_price, :float
    add_column :quote_tickers, :ma5_price, :float
  end
end
