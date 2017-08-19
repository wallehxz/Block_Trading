class CreateBlockParities < ActiveRecord::Migration
  def change
    create_table :block_parities do |t|
      t.string  :block
      t.float   :agio_rate
      t.float   :agio_price
      t.boolean :state
      t.timestamps null: false
    end
  end
end
