class CreateBlocks < ActiveRecord::Migration
  def change
    create_table :blocks do |t|
      t.string :chinese
      t.string :english

      t.timestamps null: false
    end
  end
end
