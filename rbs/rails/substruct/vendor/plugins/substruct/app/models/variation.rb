# Holds information about how the product varies.
#
class Variation < Item
  belongs_to :product
  
  #############################################################################
  # CALLBACKS
  #############################################################################
  
  after_save :update_parent_quantity
  def update_parent_quantity
    self.product.update_attribute('variation_quantity', self.product.variations.sum('quantity'))
  end
  
  #############################################################################
  # CLASS METHODS
  #############################################################################
  
  # References parent product images collection.
  #
  def images
    self.product.images
  end

  # Display name...includes product name as well
  def name
    if self.product
      return "#{self.product.name} - #{self.attributes['name']}"
    else
      return self.attributes['name']
    end
  end
  
  def short_name
    self.attributes['name']
  end
  
end