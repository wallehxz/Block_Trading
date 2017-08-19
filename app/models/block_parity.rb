# t.string   "block",      limit: 255
# t.float    "agio_rate",  limit: 24
# t.float    "agio_price", limit: 24
# t.boolean  "state"
class BlockParity < ActiveRecord::Base
  validates_presence_of :block
  has_many :sources, class_name:'PartitySource',foreign_key:'block_parity_id'

end
