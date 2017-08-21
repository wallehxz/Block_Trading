class CreateQuotes < ActiveRecord::Migration
  def change
    create_table :quotes do |t|
      t.string  :platform
      t.string  :block
      t.string  :source
      t.string  :anchor
      t.float   :increase
      t.float   :decline
      t.boolean :state

      t.timestamps null: false
    end
  end
end
