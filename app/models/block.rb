# t.string   "chinese",    limit: 255
# t.string   "english",    limit: 255
# t.datetime "created_at",             null: false
# t.datetime "updated_at",             null: false

class Block < ActiveRecord::Base
  validates_presence_of :chinese, :english
  validates_uniqueness_of :chinese, :english
  has_one :balance, class_name:'Balance', foreign_key:'block',primary_key:'english'
  self.per_page = 10

  def self.generate_md5(time)
      sign_string = "#{Settings.btc_key}_#{Settings.btc_id}_#{Settings.btc_secret}_#{time}"
      sign = Digest::MD5.hexdigest(sign_string)
  end
end