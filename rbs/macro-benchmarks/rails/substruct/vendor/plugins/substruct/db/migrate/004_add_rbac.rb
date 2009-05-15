#
# Adds table support for Role Based Access Control
#
#
class AddRbac < ActiveRecord::Migration
	def self.up 
		create_table :roles_users, :id => false do |t| 
			t.column "role_id", :integer 
			t.column "user_id", :integer 
		end 
		
		create_table :roles do |t| 
			t.column "name", :string 
			t.column "description", :text
		end 
		
		create_table :rights_roles, :id => false do |t| 
			t.column "right_id", :integer 
			t.column "role_id", :integer 
		end 

		create_table :rights do |t| 
			t.column "name", :string 
			t.column "controller", :string 
			t.column "actions", :string
		end
		
		puts 'Adding default rights...'
		# Load in new roles - otherwise nobody would have access!
		rights = Right.create(
			[ 
				{ :name => 'Orders - Admin', :controller => 'orders', :actions => '*' }, 
				{ :name => 'Users - Admin', :controller => 'users', :actions => '*' }, 
				{ :name => 'Rights - Admin', :controller => 'rights', :actions => '*' }, 
				{ :name => 'Products - Admin', :controller => 'products', :actions => '*' },
				{ :name => 'Content - Admin', :controller => 'content_nodes', :actions => '*' }, 
				{ :name => 'Questions - Admin', :controller => 'questions', :actions => '*' }, 
				{ :name => 'Roles - Admin', :controller => 'roles', :actions => '*' }, 
				{ :name => 'Tags - Admin', :controller => 'tags', :actions => '*' },
				{ :name => 'Orders - CRUD', :controller => 'orders', :actions => 'new,create,edit,update,destroy' },
				{ :name => 'Orders - View', :controller => 'orders', :actions => 'index,list,search,edit,show' }, 
				{ :name => 'Content - CRUD', :controller => 'content_nodes', :actions => 'new,create,edit,update,destroy' },
				{ :name => 'Content - View', :controller => 'content_nodes', :actions => 'index,list,search,edit,show' },
				{ :name => 'Products - CRUD', :controller => 'products', :actions => 'new,create,edit,update,destroy' },
				{ :name => 'Products - View', :controller => 'products', :actions => 'index,list,search,edit,show' },
				{ :name => 'Questions - CRUD', :controller => 'questions', :actions => 'new,create,edit,update,destroy' },
				{ :name => 'Questions - View', :controller => 'questions', :actions => 'index,list,search,edit,show' },
				{ :name => 'Tags - CRUD', :controller => 'tags', :actions => 'new,create,edit,update,destroy' },
				{ :name => 'Tags - View', :controller => 'tags', :actions => 'index,list,search,edit,show' }
			]
		)
		puts 'Creating Admin role...'
		admin_role = Role.create(:name => 'Administrator', :description => 'Access everything in Substruct.')
		# Add admin rights to our new admin role
		puts 'Assigning rights to Admin role...'
		admin_role.rights << Right.find(:all, :conditions => "name LIKE '%Admin'")
		# Give everyone admin rights - like it was before RBAC
		puts 'Giving all existing users the Admin role...'
		users = User.find(:all)
		for user in users
			user.roles << admin_role
		end
		
	end
	 
	def self.down 
		drop_table :roles_users 
		drop_table :roles 
		drop_table :rights 
		drop_table :rights_roles 
	end
	
end
