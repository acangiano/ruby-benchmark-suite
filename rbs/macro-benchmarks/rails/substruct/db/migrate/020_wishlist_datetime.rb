class WishlistDatetime < ActiveRecord::Migration
  def self.up
    change_column :wishlist_items, :created_on, :datetime
  end
  
  def self.down
    change_column :wishlist_items, :created_on, :date
  end
end