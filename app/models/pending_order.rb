# t.string   "block",       limit: 255
# t.string   "business",    limit: 255
# t.float    "amount",      limit: 24
# t.float    "price",       limit: 24
# t.float    "consume",     limit: 24
# t.integer  "state"        default: false
# t.datetime "created_at",  null: false
# t.datetime "updated_at",  null: false

class PendingOrder < ActiveRecord::Base
  validates_presence_of :block, :amount, :price, :business
  self.per_page = 10
  after_save :calculate_consume
  after_save :sync_order

  def maimai
    {'1'=>'买入','2'=>'卖出'}[self.business]
  end

  def zhuangtai
    {0=>'未激活',2=>'未生效',1=>'已挂单'}[self.state]
  end

  def calculate_consume
    if self.consume.nil?
      self.update_attributes(consume: self.amount * self.price)
    elsif self.consume != (self.amount * self.price)
      self.update_attributes(consume: self.amount * self.price)
    end
  end

  def sync_order
    if self.state == 0
      res = PendingOrder.remote_order(self.block,self.business,self.price,self.amount)
      if res.include?('succ')
        #邮件通知 send_business_email(order,email)
        return self.update_attributes(state: 1)
      end
      self.update_attributes(state: 2)
    end
  end

  def self.remote_order(bolck,business,price,amount)
    time = Time.now.to_i
    body_hash = {}
    body_hash['key'] = Settings.btc_key
    body_hash['skey'] = Settings.btc_secret
    body_hash['time'] = time
    body_hash['md5'] = Block.generate_md5(time)
    body_hash['type'] = business
    body_hash['mk_type'] = 'cny'
    body_hash['price'] = price
    body_hash['amount'] = amount
    body_hash['coinname'] = bolck
    res = Faraday.post do |req|
      req.url 'http://api.btc38.com/v1/submitOrder.php'
      req.body = body_hash
    end
    res.body rescue ''
  end

end