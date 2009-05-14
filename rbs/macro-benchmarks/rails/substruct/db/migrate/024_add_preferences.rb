# Adds preferences table, for values that we can set via the UI.
#
# This stuff used to be scattered about in config files, 
# which was a big fucking mess.
#
class AddPreferences < ActiveRecord::Migration
  def self.up
		create_table(:preferences, :options => 'DEFAULT CHARSET=UTF8 ENGINE=InnoDB') do |t|
      t.column "name", :string, :null => false
      t.column "value", :string, :default => ''
    end
    add_index 'preferences', ['name'], :name => 'namevalue'
    
    # Add default preferences!
    Preference.reset_column_information
    Preference.create([
      { :name => 'cc_processor', :value => Preference::CC_PROCESSORS[0] },
      { :name => 'cc_login', :value => '' },
      { :name => 'cc_pass', :value => '' },
      { :name => 'cc_clear_after_order', :value => true },
      { :name => 'store_name', :value => 'Substruct' },
      { :name => 'store_home_country', :value => '1' },
      { :name => 'store_show_confirmation', :value => true },
      { :name => 'store_use_inventory_control', :value => true },
      { :name => 'store_require_login', :value => false },
      { :name => 'store_handling_fee', :value => '15.00' },
      { :name => 'mail_copy_to', :value => '' },
      { :name => 'mail_host', :value => 'localhost' },
      { :name => 'mail_port', :value => '25' },
      { :name => 'mail_auth_type', :value => Preference::MAIL_AUTH[0] },
      { :name => 'mail_username', :value => '' },
      { :name => 'mail_password', :value => '' }
    ])
  end
  
  def self.down
    drop_table :preferences
  end
end
