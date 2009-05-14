# Adds the concept of ProductVariations
#
# Renames product table to items.
#
#
#
class ProductVariations < ActiveRecord::Migration
  def self.up
    add_column :products, :type, :string, :limit => 40
    add_column :products, :product_id, :integer, :default => 0, :null => false
    # Rename table for STI
    rename_table :products, :items
    # Set all existing types to "Product"
    Item.update_all("type = 'Product'")
    rename_column :order_line_items, :product_id, :item_id
  end
  
  def self.down
    remove_column :items, :type
    remove_column :items, :product_id
    # Rename again...
    rename_table :items, :products
    rename_column :order_line_items, :item_id, :product_id
  end
end