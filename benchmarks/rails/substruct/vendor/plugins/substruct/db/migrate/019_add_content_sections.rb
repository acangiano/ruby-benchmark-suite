class AddContentSections < ActiveRecord::Migration
  def self.up
		# Add order weights
		create_table(:sections, :options => 'DEFAULT CHARSET=UTF8 ENGINE=InnoDB') do |t|
      t.column "name",      :string, :limit => 100, :default => "", :null => false
      t.column "rank",      :integer
      t.column "parent_id", :integer, :default => 0,  :null => false
    end
    create_table :content_nodes_sections, :id => false, :force => true do |t|
      t.column "content_node_id", :integer, :default => 0, :null => false
      t.column "section_id",     :integer, :default => 0, :null => false
    end
    add_index "content_nodes_sections", ["content_node_id", "section_id"], :name => "default"
    
    # Add permissions for admins to edit prefs
		puts 'Creating Section rights'
		rights = Right.create(
			[ 
				{ :name => 'Sections - Admin', :controller => 'sections', :actions => '*' }
			]
		)
		puts 'Assigning rights to Admin role...'
		admin_role = Role.find_by_name('Administrator')
		admin_role.rights.clear
		admin_role.rights << Right.find(:all, :conditions => "name LIKE '%Admin'")
  end

  def self.down
    drop_table :sections
    drop_table :content_nodes_sections
    
    puts 'Removing section rights'
		rights = Right.find(:all, :conditions => "name LIKE 'Sections%'")
		for right in rights
		  right.destroy
	  end
  end
end