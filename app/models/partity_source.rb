# t.integer  "block_parity_id", limit: 4
# t.string   "platform",        limit: 255
# t.string   "ticker_url",      limit: 255
# t.string   "css_anchor",      limit: 255
# t.float    "last_price",      limit: 24
class PartitySource < ActiveRecord::Base
  validates_presence_of :block_parity_id, :platform, :ticker_url
  after_save :sync_anchor
  scope :price, ->{order(last_price: :desc)}

  def sync_anchor
    if self.css_anchor.blank?
      self.update_attributes(css_anchor:PartitySource.platform_to_price(self.ticker_url))
    end
  end

  def self.platform_to_price(url)
    if url.include?('k.sosobtc.com')
      return 'div#price'
    else
      return 'div.price'
    end
  end

end
