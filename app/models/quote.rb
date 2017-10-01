# t.string   "platform",   limit: 255
# t.string   "block",      limit: 255
# t.string   "source",     limit: 255
# t.string   "anchor",     limit: 255
# t.float    "increase",   limit: 24
# t.float    "decline",    limit: 24
# t.boolean  "state"
class Quote < ActiveRecord::Base
  after_save :sync_anchor
  has_many :tickers, class_name:'QuoteTicker',foreign_key:'quote_id'

  def sync_anchor
    if self.anchor.blank?
      self.update_attributes(anchor:PartitySource.platform_to_price(self.source))
    end
  end

  def ma5_one
    (self.tickers.last(5).map {|x| x.last_price }.sum / 5).round(6)
  end

  def ma5_two
    array = self.tickers.last(6).map {|x| x.last_price }
    ((array.sum - array[-1]) / 5).round(6)
  end

  def ma5_three
    array = self.tickers.last(7).map {|x| x.last_price }
    ((array.sum - array[-1] - array[-2]) / 5).round(6)
  end

  def sync_price
    res =  Faraday.get self.source
    info = JSON.parse(res.body)
    price = info['buyStr'][0][0]
  end

end
