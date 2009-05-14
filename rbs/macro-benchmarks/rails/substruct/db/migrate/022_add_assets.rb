# Adding assets as a general item.
#
# This is the data support allowing admins to upload content for the
# blog including, but not limited to images.
#
# We classify images as a special item so we can still link em
# to products easily.
#
class AddAssets < ActiveRecord::Migration
  require 'fileutils'
  
  def self.up
    # All assets up to this point are images, make it so.
    add_column :images, :type, :string
    add_column :images, :created_on, :datetime
    rename_table :images, :user_uploads
    add_index :user_uploads, ["created_on", "type"], :name => "creation"
    UserUpload.update_all("type = 'Image'")
    # For existing installs we need to move the directory we
    # had set up using "images" or shit will FAIL.
    if File.exists?(File.join(RAILS_ROOT, "public/system/image"))
      # Remove the auto-created path for user_upload
      FileUtils.rm_rf(File.join(RAILS_ROOT, "public/system/user_upload"))
      #
      puts "Moving old images directory to reflect new data structure..."
      FileUtils.mv(File.join(RAILS_ROOT, "public/system/image"), File.join(RAILS_ROOT, "public/system/user_upload"))
      puts "...done."
    end
    
    # Add permissions for admins to edit prefs
		puts 'Creating file rights'
		rights = Right.create(
			[ 
				{ :name => 'Files - Admin', :controller => 'files', :actions => '*' }
			]
		)
		puts 'Assigning rights to Admin role...'
		admin_role = Role.find_by_name('Administrator')
		admin_role.rights.clear
		admin_role.rights << Right.find(:all, :conditions => "name LIKE '%Admin'")
  end
  
  def self.down
    remove_index :user_uploads, :name => "creation"
    remove_column :user_uploads, :type
    remove_column :user_uploads, :created_on
    rename_table :user_uploads, :images
    # Move dir back
    if File.exists?(File.join(RAILS_ROOT, "public/system/user_upload"))
      puts "Reverting to old images directory structure..."
      FileUtils.mv(File.join(RAILS_ROOT, "public/system/user_upload"), File.join(RAILS_ROOT, "public/system/image"))
      puts "...done."
    end
    
    puts 'Removing file rights'
		rights = Right.find(:all, :conditions => "name LIKE 'Files%'")
		for right in rights
		  right.destroy
	  end
  end
end
