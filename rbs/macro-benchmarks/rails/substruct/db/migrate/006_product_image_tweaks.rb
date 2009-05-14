# Adds support that allows setting a default product image.
#
# Turns images_products table into ProductImages table...
#
class ProductImageTweaks < ActiveRecord::Migration
  def self.up
    add_column :images_products, :id, :primary_key
    add_column :images_products, :rank, :integer
    rename_table :images_products, :product_images
  end
  
  def self.down
    rename_table :product_images, :images_products
    remove_column :images_products, :id
    remove_column :images_products, :rank
  end
end