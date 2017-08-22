# t.integer  "block_id",   limit: 4
# t.float    "last_price", limit: 24
# t.float    "buy_price",  limit: 24
# t.float    "sell_price", limit: 24
# t.date     "that_date"
# t.float    "ma5_price",  limit: 24

class BlockTicker < ActiveRecord::Base
  validates_presence_of :last_price, :buy_price, :sell_price, :that_date
  scope :latest, -> { order(created_at: :desc)}
  after_save :sync_ma5

  self.per_page = 12

  def three_historical
    before_day = Date.current.yesterday.to_s
    before_three_day = (Date.current - 3.day).to_s
  end

  def sync_ma5
    if self.ma5_price.nil?
      self.update_attributes(ma5_price:self.recent_five)
    end
  end

  def recent_five
    five_array = BlockTicker.where('id <= ? and block_id = ?',self.id,self.block_id).last(5).map {|x| x.last_price}
    return (five_array.sum / 5).round(6) if five_array.count == 5
    return self.last_price
  end
end
