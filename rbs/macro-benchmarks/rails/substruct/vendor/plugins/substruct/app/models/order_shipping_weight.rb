# These are the "variations" of an OrderShippingType
#
# They allow an admin to specify weight ranges and prices
# for an OrderShippingType.
#
#
class OrderShippingWeight < ActiveRecord::Base
  belongs_to :order_shipping_type
  validates_presence_of :price
  validates_numericality_of :price
end