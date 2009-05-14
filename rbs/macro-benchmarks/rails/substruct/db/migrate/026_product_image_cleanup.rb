# Cleans up all unrelated products / images
#
class ProductImageCleanup < ActiveRecord::Migration
  def self.up
    ProductImage.find(:all).each do |pi|
      pi.destroy if pi.image.nil?
    end
  end
  
  def self.down
    ## can't reverse
  end
end