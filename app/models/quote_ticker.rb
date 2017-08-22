# t.integer  "quote_id",   limit: 4
# t.float    "last_price", limit: 24
# t.date     "that_date"
# t.float    "ma5_price",  limit: 24
class QuoteTicker < ActiveRecord::Base

  after_save :sync_ma5

  def sync_ma5
    if self.ma5_price.nil?
      self.update_attributes(ma5_price:self.recent_five)
    end
  end

  def recent_five
    five_array = QuoteTicker.where('id <= ? and quote_id = ?',self.id,self.quote_id).last(5).map {|x| x.last_price }
    return (five_array.sum / 5).round(6) if five_array.count == 5
    return self.last_price
  end
end
