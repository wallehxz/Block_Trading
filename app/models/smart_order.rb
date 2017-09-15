# t.integer  "focus_id",   limit: 4
# t.string   "business"
# t.string   "factor",     limit: 255
# t.float    "scale",      limit: 24
# t.float    "amount",     limit: 24
# t.float    "expect",     limit: 24
# t.boolean  "state"
# t.datetime "created_at",             null: false
# t.datetime "updated_at",             null: false

class SmartOrder < ActiveRecord::Base
  scope :stated, -> { order(state: :asc)}
  validates_presence_of :expect, :business, :factor
  def business_cn
    {'1'=>'买入','2'=>'卖出'}[self.business]
  end

  def factor_cn
    {'>'=>'大于','<'=>'小于'}[self.factor]
  end

  def scale_cn
    return "#{self.scale * 100}%" if self.scale.present?
    self.amount
  end

  def state_cn
    {false=>'未生效',true=>'已挂单'}[self.state]
  end
end
