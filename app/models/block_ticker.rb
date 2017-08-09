# t.integer  "block_id",   limit: 4
# t.float    "last_price", limit: 24
# t.float    "buy_price",  limit: 24
# t.float    "sell_price", limit: 24
# t.date     "that_date"

class BlockTicker < ActiveRecord::Base
  validates_presence_of :last_price, :buy_price, :sell_price, :that_date
  scope :latest, -> { order(created_at: :desc)}
  self.per_page = 12

  def three_historical
    before_day = Date.current.yesterday.to_s
    before_three_day = (Date.current - 3.day).to_s

  end
end
