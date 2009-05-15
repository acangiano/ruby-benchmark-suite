# Adds paypal ipn support.
#
class AddPaypalIpn < ActiveRecord::Migration
  def self.up
    # Paypal transaction id's are alphanumeric.
    change_column :orders, :auth_transaction_id, :string
    # Is the site in order test mode?
    Preference.create(:name => 'store_test_transactions', :value => '1')
  end
  
  def self.down
    change_column :orders, :auth_transaction_id, :integer
    Preference.destroy_all("name = 'store_test_transactions'")
  end
end