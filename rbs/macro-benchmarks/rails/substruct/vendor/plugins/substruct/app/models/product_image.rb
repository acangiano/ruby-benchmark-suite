# Represents a connection from an image to a product.
#
#
class ProductImage < ActiveRecord::Base
  belongs_to :product
  belongs_to :image
end