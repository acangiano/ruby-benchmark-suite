# Adds an index to order_addresses on country and order user.
#
# This speeds up the newly added orders by country report.
#
class AddCountryIndex < ActiveRecord::Migration
  def self.up
    add_index "order_addresses", ["country_id", "order_user_id"], :name => "countries"
  end
  
  def self.down
    remove_index "order_addresses", :name => "countries"
  end
end