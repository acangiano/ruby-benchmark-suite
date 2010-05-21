class OrderLineItem < ActiveRecord::Base
  belongs_to :product
  belongs_to :item
  belongs_to :order
  alias_attribute :price, :unit_price
  
 validates_numericality_of :quantity, :greater_than_or_equal_to => 1, :only_integer => true, :message => "must be positive"
  
  # Creates and returns a line item when a product is passed in
  def self.for_product(item)
    ol_item = self.new
    ol_item.quantity = 1
    ol_item.item = item
    ol_item.name = item.name
    ol_item.unit_price = item.price
    return ol_item
  end

  def total
    self.quantity * self.unit_price.to_i
  end
  
  # We still have view code referencing product_id
  # Since we changed to variations / products we need
  # to use item_id.
  #
  def product_id
    self.item_id
  end
  
  def product
    self.item
  end
  
  def code
    self.item.code
  end
  
  def name
    if !self.item.nil?
      return self.item.name
    else
      return self.attributes['name']
    end
  end
end
