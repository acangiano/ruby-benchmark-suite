# Takes all order_users with multiple entries and slims them down.
#
# I added a restriction to only allow unique emails in the order_users table.
# This is a precursor to customer logins, wishlist, and order tracking.
#
# Also links Orders directly with OrderAccounts and OrderAddresses now
# since a particular user might use many of these for the life of
# their account.
#
class CondenseOrderUsers < ActiveRecord::Migration
  
  def self.up
    add_column :order_accounts, :order_id, :integer, :default => 0, :null => false
    add_column :order_addresses, :order_id, :integer, :default => 0, :null => false

		# Adds a table for promotions
    create_table(:wishlist_items, :options => 'DEFAULT CHARSET=UTF8 ENGINE=InnoDB') do |t|
      t.column :order_user_id, :integer, :null => false
      t.column :item_id, :integer, :null => false
      t.column :created_on, :date
		end
		add_index :wishlist_items, ["order_user_id"], :name => "user"
    add_index :wishlist_items, ["item_id"], :name => "item"

    OrderAccount.reset_column_information
    OrderAddress.reset_column_information

    # Now set order_id's for other items in the DB
    puts "Updating order_id's for OrderAccounts..."
    accounts = OrderAccount.find(:all)
    orphan_accounts = 0
    for a in accounts
      if a.order_id == 0 && a.order_user && a.order_user.last_order
        a.update_attribute("order_id", a.order_user.last_order.id)
      else
        orphan_accounts += 1
      end
    end

    puts "Updating order_id's for OrderAddresses..."
    addresses = OrderAddress.find(:all)
    orphan_addresses = 0
    for a in addresses
      if a.order_id == 0 && a.order_user && a.order_user.last_order
        a.update_attribute("order_id", a.order_user.last_order.id)
      else
        orphan_addresses += 1
      end
    end
    
    puts "Orphan OrderAccounts: #{orphan_accounts}"
    puts "Orphan OrderAddresses: #{orphan_addresses}"

    # Get all duplicate user emails
    puts "Getting duplicate user emails..."
    dupe_user_emails = OrderUser.find_by_sql(%q/
      SELECT email_address, COUNT(email_address) AS number_times
      FROM order_users
      GROUP BY email_address
      HAVING ( number_times > 1 )
      ORDER BY number_times DESC
    /)
    puts "Got em..."
    for record in dupe_user_emails
      # Go through each email, get OrderUser records for each
      dupe_users = OrderUser.find(
        :all,
        :conditions => ["email_address = ?", record.email_address]
      )
      puts "...Working for #{record.email_address}..."
      # We'll save the 1st one. Delete the rest later...
      id_to_save = dupe_users[0].id
      dupe_users.each_with_index do |item, index|
        # Skip 0
        next if index == 0
        # We have an order > order_user 1:1 relationship, so find that order id
        # ...We'll use it to update shit later on.
        order = Order.find_by_order_user_id(item.id)
        if order
          order_id = order.id
        else
          order_id = 0
        end
        # Go through the following tables...
        # - order_accounts
        # - order_addresses
        # - orders
        # 
        # Update order_user_id to the one we're keeping
        OrderAccount.update_all(
          "order_user_id = #{id_to_save}, order_id = #{order_id}", 
          "order_user_id = #{item.id}"
        )
        OrderAddress.update_all(
          "order_user_id = #{id_to_save}, order_id = #{order_id}", 
          "order_user_id = #{item.id}"
        )
        Order.update_all(
          "order_user_id = #{id_to_save}", 
          "order_user_id = #{item.id}"
        )
        # Delete the dupe order_users.
        item.destroy
      end # dupe users...
      puts "Dupes removed, moving on."
    end # for
  end

  def self.down
    # Can't really un-delete records...
    remove_column :order_accounts, :order_id 
    remove_column :order_addresses, :order_id
    drop_table :wishlist_items
  end
end