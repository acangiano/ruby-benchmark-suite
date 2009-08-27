# Adds wishlist support
#
class RelatedProducts < ActiveRecord::Migration
  def self.up
		# Adds a table for promotions
    create_table(:related_products, :options => 'DEFAULT CHARSET=UTF8 ENGINE=InnoDB', :id => false) do |t|
      t.column :product_id, :integer, :null => false
      t.column :related_id, :integer, :null => false
		end
  end

  def self.down
		drop_table :related_products
	end
end