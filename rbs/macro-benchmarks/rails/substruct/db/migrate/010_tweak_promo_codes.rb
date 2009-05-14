class TweakPromoCodes < ActiveRecord::Migration
  def self.up		
		# Add promotion ID to the orders table.
		# Users enter a code, but it links via promotion ID.
		add_column :promotions, :start, :datetime, :null => false
		add_column :promotions, :end, :datetime, :null => false
		add_column :promotions, :minimum_cart_value, :float
		add_column :promotions, :description, :string, :default => '', :null => false
		remove_column :promotions, :is_active
		rename_column :promotions, :product_id, :item_id
		
		add_column :order_line_items, :name, :string, :default => ''
		
		Promotion.update_all("start = CURRENT_DATE")
		Promotion.update_all("end = CURRENT_DATE")
  end

  def self.down
    add_column :promotions, :is_active, :boolean, :default => true, :null => false
    remove_column :promotions, :start
    remove_column :promotions, :end
    remove_column :promotions, :minimum_cart_value
    remove_column :promotions, :description
		rename_column :promotions, :item_id, :product_id
		
		remove_column :order_line_items, :name
  end
end