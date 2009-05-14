# Cleaning up the shipping associations and hopefully shut
# everyone up about this once and for all :p
#
# On top of that, should improve clarity of the ordering system
# and process.
#
class FixShippingAssociations < ActiveRecord::Migration
  # class Order < ActiveRecord::Base; end
  # class OrderAddress < ActiveRecord::Base; end
  # class OrderUser < ActiveRecord::Base; end
  # class OrderAccount < ActiveRecord::Base; end
  
  
  def self.up
    add_column :orders, :shipping_address_id, :integer, :default => 0, :null => false
    add_column :orders, :billing_address_id, :integer, :default => 0, :null => false
    add_column :orders, :order_account_id, :integer, :default => 0, :null => false
    
    add_column :order_users, :first_name, :string, :limit => 50, :default => "", :null => false
    add_column :order_users, :last_name, :string, :limit => 50, :default => "", :null => false    
    
    Order.reset_column_information
    OrderUser.reset_column_information
    
    # Fill the proper associations
    addys = OrderAddress.find(:all)
    puts "Updating associations for addresses."
    for addy in addys do
      # Find order and set proper association.
      # If no order, this is an orphan - delete.
      o = Order.find_by_id(addy.order_id)
      if !o
        puts "This address doesn't link to a valid order - destroying"
        puts addy.inspect
        addy.destroy
        next
      end
      if addy.is_shipping?
        o.update_attribute(:shipping_address_id, addy.id)
      else
        o.update_attribute(:billing_address_id, addy.id)
      end
      putc '.'
    end
    puts "...done"
    
    accounts = OrderAccount.find(:all)
    for acc in accounts do
      # Find order and set proper association.
      # If no order, this is an orphan - delete.
      o = Order.find_by_id(acc.order_id)
      if !o
        puts "This account doesn't link to a valid order - destroying"
        puts acc.inspect
        acc.destroy
        next
      end
      o.update_attribute(:order_account_id, acc.id)
    end
    
    # Loop through orders.
    # Use same address for ones that don't have billing or shipping.
    # Alert for ones that don't have either...(SHOULDNT HAPPEN!!!)
    puts "Updating orders to make sure they have billing and shipping addresses."
    orders = Order.find(:all)
    orders_with_no_address = 0
    orders_with_no_account = 0
    for o in orders do
      if o.billing_address_id == 0 && o.shipping_address_id == 0
        puts "No billing or shipping address for this one..."
        puts o.inspect
        puts "...deleting"
        o.destroy
        orders_with_no_address += 1
        next
      end
      if o.billing_address_id == 0
        o.update_attribute(:billing_address_id, o.shipping_address_id)
      elsif o.shipping_address_id == 0
        o.update_attribute(:shipping_address_id, o.billing_address_id)
      end
      if o.order_account_id == 0
        puts "NO ACCOUNT ASSOCIATED WITH THIS ORDER!!!"
        orders_with_no_account += 1
      end
    end
    
    puts "Orders with no addresses associated (deleted): #{orders_with_no_address}"
    puts "Orders with no account associated (kept): #{orders_with_no_account}"
    
    # Fill in first and last name for OrderUsers based on
    # the latest billing address. This is what we were using as default
    # before the changeover.
    users = OrderUser.find(:all)
    for u in users do
      if !u.last_order
        puts "No last order for..."
        puts u.inspect
        next
      end
      u.update_attributes(
        {
          :first_name => u.last_order.billing_address.first_name,
          :last_name => u.last_order.billing_address.last_name
        }
      )
    end
    
    # Remove unused columns
    remove_column :order_addresses, :is_shipping
    remove_column :order_addresses, :order_id

    remove_column :order_accounts, :order_address_id
    remove_column :order_accounts, :order_id

  end
  
  # Because of code changes in model associations, 
  # backtracking completely is probably not possible...
  #
  def self.down
    add_column :order_addresses, :is_shipping, :boolean, :default => false, :null => false
    add_column :order_addresses, :order_id, :integer, :default => 0, :null => false

    add_column :order_accounts, :order_address_id, :integer, :default => 0, :null => false
    add_column :order_accounts, :order_id, :integer, :default => 0, :null => false

    # Backtrack and refill the proper associations?
    orders = Order.find(:all)
    for o in orders do
      addy = OrderAddress.find_by_id(o.shipping_address_id)
      addy.update_attributes(
        {
          :is_shipping => true,
          :order_id => o.id
        }
      ) if addy
      addy = OrderAddress.find_by_id(o.billing_address_id)
      addy.update_attributes(
        {
          :is_shipping => false,
          :order_id => o.id
        }
      ) if addy
      account = OrderAccount.find_by_id(o.order_account_id)
      account.update_attribute(:order_id, o.id) if account
    end
    
    # Remove unused columns
    remove_column :orders, :shipping_address_id
    remove_column :orders, :billing_address_id
    remove_column :orders, :order_account_id

    remove_column :order_users, :first_name
    remove_column :order_users, :last_name
  end
end
