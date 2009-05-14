class AddOrderShippingWeights < ActiveRecord::Migration
  def self.up
    # Clean up order_shipping_types table...
    add_column :order_shipping_types, :price, :float, :limit => 10, :default => 0.0, :null => false
    change_column :order_shipping_types, :is_domestic, :boolean, :default => true, :null => false
    # Make sure tax is set to 0 by default on orders.
    change_column :orders, :tax, :float, :default => 0.0, :null => false
    # Kill columns un-necessary now
    remove_column :order_shipping_types, :company
    remove_column :order_shipping_types, :service_type
    remove_column :order_shipping_types, :transaction_type
    remove_column :order_shipping_types, :shipping_multiplier
    remove_column :order_shipping_types, :flat_fee
    
		# Add preferences table
		
		# Add order weights
		create_table(:order_shipping_weights, :options => 'DEFAULT CHARSET=UTF8 ENGINE=InnoDB') do |t|
      t.column "order_shipping_type_id", :integer, :default => 0, :null => false
      t.column "min_weight", :float, :limit => 10, :default => 0.0, :null => false
      t.column "max_weight", :float, :limit => 10, :default => 0.0, :null => false
      t.column "price", :float, :limit => 10, :default => 0.0, :null => false
    end
		
		# Add permissions for admins to edit prefs
		puts 'Creating Preference rights'
		rights = Right.create(
			[ 
				{ :name => 'Preferences - Admin', :controller => 'preferences', :actions => '*' }
			]
		)
		puts 'Assigning rights to Admin role...'
		admin_role = Role.find_by_name('Administrator')
		admin_role.rights.clear
		admin_role.rights << Right.find(:all, :conditions => "name LIKE '%Admin'")
  end

  def self.down
    remove_column :order_shipping_types, :price
    change_column :order_shipping_types, :is_domestic, :boolean, :default => false, :null => false
    
    # re-add columns
    add_column :order_shipping_types, :company, :string, :limit => 20
    add_column :order_shipping_types, :service_type, :string, :limit => 50
    add_column :order_shipping_types, :transaction_type, :string, :limit => 50
    add_column :order_shipping_types, :shipping_multiplier, :float, :default => 0.0, :null => false
    add_column :order_shipping_types, :flat_fee, :float, :default => 0.0, :null => false
    
    # Drop table for OrderShippingWeight
    drop_table :order_shipping_weights

		puts 'Removing promotion rights'
		rights = Right.find(:all, :conditions => "name LIKE 'Preferences%'")
		for right in rights
		  right.destroy
	  end
  end
end