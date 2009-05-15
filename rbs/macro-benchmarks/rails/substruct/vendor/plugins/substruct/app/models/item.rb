# This is the base model for Product and ProductVariation.
#
#
class Item < ActiveRecord::Base
  has_many :order_line_items
  has_many :wishlist_items, :dependent => :destroy
  validates_presence_of :name, :code
  validates_uniqueness_of :code
  
  #############################################################################
  # CALLBACKS
  #############################################################################
  
  # DB complains if there's not a date available set.
  # This is a cheap fix.
  before_save :set_date_available
  def set_date_available
    self.date_available = Date.today if !self.date_available
  end

  #############################################################################
  # CLASS METHODS
  #############################################################################


  #############################################################################
  # INSTANCE METHODS
  #############################################################################

  # Name output for product suggestion JS
  # 
  def suggestion_name
    "#{self.code}: #{self.name}"
  end
  
end
