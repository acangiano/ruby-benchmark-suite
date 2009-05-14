class BoostIndexes < ActiveRecord::Migration
  def self.up
    add_index :tags, ['name'], :name => 'name'
    add_index :items, ['product_id', 'type'], :name => 'variation'
    add_index :items, ['date_available', 'is_discontinued', 'quantity', 'variation_quantity', 'type'], :name => 'tag_view'
    add_index :items, ['name', 'code', 'is_discontinued', 'date_available', 'quantity', 'variation_quantity', 'type'], :name => 'search'
    add_index :products_tags, ['product_id', 'tag_id'], :name => 'product_tags'
    add_index :related_products, ['product_id', 'related_id'], :name => 'related_products'
  end
  
  def self.down
    remove_index :tags, :name => 'name'
    remove_index :items, :name => 'variation'
    remove_index :items, :name => 'tag_view'
    remove_index :items, :name => 'search'
    remove_index :products_tags, :name => 'product_tags'
    remove_index :related_products, :name => 'related_products'
  end
end