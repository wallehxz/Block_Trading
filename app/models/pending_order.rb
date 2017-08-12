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
  belongs_to :chain, class_name:'Block', primary_key:'english', foreign_key:'block'
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
      tip = PendingOrder.loop_order_request(self.block,self.business,self.price,self.amount)
      if tip.to_s.include?('succ')
        Notice.business_notice(Settings.receive_email,self).deliver_now
        PendingOrder.sync_balance(self)
        return self.update_attributes(state: 1)
      else
        msg = "<p>#{self.block} 挂单#{self.maimai}失败，导致原因: #{tip}，请知悉，如有必要，请反馈给开发者,提升系统运行体验</p>"
        Notice.info_notice(Settings.receive_email,msg).deliver_now
      end
      self.update_attributes(state: 2)
    end
  end

  def self.sync_balance(order)
    if order.business == '1'
      if balance = Balance.find_by_block(order.block)
        balance.update_attributes(buy_price:order.price)
      else
        Balance.create(block:order.block,buy_price:order.price)
      end
    elsif order.business == '2'
      if balance = Balance.find_by_block(order.block)
        balance.update_attributes(sell_price:order.price)
      else
        Balance.create(block:order.block,sell_price:order.price)
      end
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

  def self.loop_order_request(bolck,business,price,amount)
      5.times do |i|
        tip = PendingOrder.remote_order(bolck,business,price,amount)
        return tip if tip.include?('succ')
      end
  end


end