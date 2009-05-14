# Adds a discontinued flag to items.
# Discontinued products remain on the site until their stock runs out.
#
# Also adds variation quantity so that we can easily look up products
# that have variations in stock.
#
class AddDiscontinuedFlag < ActiveRecord::Migration
  def self.up		
		add_column :items, :is_discontinued, :boolean, :default => false, :null => false
		add_column :items, :variation_quantity, :integer, :default => 0, :null => false
		add_index :items, ['quantity', 'is_discontinued', 'variation_quantity'], :name => "published"
  end

  def self.down
    remove_column :items, :is_discontinued
    remove_column :items, :variation_quantity
    remove_index :items, :name => 'published'
  end
end