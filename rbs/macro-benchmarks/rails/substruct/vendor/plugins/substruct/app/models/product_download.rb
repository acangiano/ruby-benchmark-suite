# Represents a connection from a download to a product.
class ProductDownload < ActiveRecord::Base
  belongs_to :product
  belongs_to :download
end