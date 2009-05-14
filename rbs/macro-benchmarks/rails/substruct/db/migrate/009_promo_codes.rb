class PromoCodes < ActiveRecord::Migration
  def self.up
		# Adds a table for promotions
		create_table :promotions do |t|
		  t.column :code, :string, :limit => 15, :default => "", :null => false
      t.column :discount_type, :integer, :default => 0, :null => false
      t.column :discount_amount, :float, :default => 0.0, :null => false
      t.column :product_id, :integer
      t.column :is_active, :boolean, :default => true, :null => false
		end
		
		# Add promotion ID to the orders table.
		# Users enter a code, but it links via promotion ID.
		add_column :orders, :promotion_id, :integer, :default => 0, :null => false
		
		# Add permissions for admins to edit promotions
		puts 'Creating Promotion rights'
		rights = Right.create(
			[ 
				{ :name => 'Promotions - Admin', :controller => 'promotions', :actions => '*' }, 
				{ :name => 'Promotions - CRUD', :controller => 'promotions', :actions => 'new,create,edit,update,destroy' },
				{ :name => 'Promotions - View', :controller => 'promotions', :actions => 'index,list,search,edit,show' },
			]
		)
		puts 'Assigning rights to Admin role...'
		admin_role = Role.find_by_name('Administrator')
		admin_role.rights.clear
		admin_role.rights << Right.find(:all, :conditions => "name LIKE '%Admin'")
  end

  def self.down
		drop_table :promotions
		remove_column :orders, :promotion_id
		#
		puts 'Removing promotion rights'
		rights = Right.find(:all, :conditions => "name LIKE 'Promotions%'")
		for right in rights
		  right.destroy
	  end
  end
end