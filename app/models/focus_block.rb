# t.integer  "block_id",       limit: 4
# t.float    "buy_amount",     limit: 24
# t.float    "total_price",    limit: 24
# t.float    "sell_weights",   limit: 24
# t.float    "sell_amplitude", limit: 24
# t.boolean  "activation"

class FocusBlock < ActiveRecord::Base
  validates_presence_of :block_id, :buy_amount, :total_price, :sell_weights, :sell_amplitude

  belongs_to :block, class_name:'Block',foreign_key:'block_id'
  has_many :tickers, class_name:'BlockTicker',foreign_key:'block_id',primary_key:'block_id'

  def zhuangtai
    {false=>'已禁用', true=>'已启用'}[self.activation]
  end

end
