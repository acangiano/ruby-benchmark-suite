# Items that make up a customer's wishlist.
#
class WishlistItem < ActiveRecord::Base
  belongs_to :order_user
  belongs_to :item
  
end