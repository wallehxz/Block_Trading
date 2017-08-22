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
end
