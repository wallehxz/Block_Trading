# t.string   "block",      limit: 255
# t.float    "amount",     limit: 24
# t.float    "buy_price",  limit: 24
# t.float    "sell_price", limit: 24
# t.datetime "created_at",             null: false
# t.datetime "updated_at",             null: false
class Balance < ActiveRecord::Base

end
