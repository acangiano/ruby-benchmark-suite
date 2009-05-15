class OrderAddressState < ActiveRecord::Migration
  def self.up
    change_column :order_addresses, :state, :string, :limit => 30
  end
  
  def self.down
    change_column :order_addresses, :state, :string, :limit => 10
  end
end
