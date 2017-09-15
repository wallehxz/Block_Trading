class CreateSmartOrders < ActiveRecord::Migration
  def change
    create_table :smart_orders do |t|
      t.integer  :focus_id
      t.string   :business
      t.string   :factor
      t.float    :scale
      t.float    :amount
      t.float    :expect
      t.boolean  :state
      t.timestamps null: false
    end
  end
end
