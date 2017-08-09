class CreatePendingOrders < ActiveRecord::Migration
  def change
    create_table :pending_orders do |t|
      t.string  :block
      t.string  :business
      t.float   :amount
      t.float   :price
      t.float   :consume
      t.integer :state,   default:0

      t.timestamps null: false
    end
  end
end
