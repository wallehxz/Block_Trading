class CreateQuoteTickers < ActiveRecord::Migration
  def change
    create_table :quote_tickers do |t|
      t.integer :quote_id
      t.float   :last_price
      t.date    :that_date

      t.timestamps null: false
    end
  end
end
