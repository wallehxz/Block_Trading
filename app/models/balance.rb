# t.string   "block",      limit: 255
# t.float    "amount",     limit: 24
# t.float    "buy_price",  limit: 24
# t.float    "sell_price", limit: 24
# t.datetime "created_at",             null: false
# t.datetime "updated_at",             null: false
class Balance < ActiveRecord::Base
  scope :named, ->{order(block: :asc)}
  scope :quantity, ->{ order(amount: :desc) }
  belongs_to :chain, class_name:'Block',primary_key:'english', foreign_key:'block'
  self.per_page = 20
end
