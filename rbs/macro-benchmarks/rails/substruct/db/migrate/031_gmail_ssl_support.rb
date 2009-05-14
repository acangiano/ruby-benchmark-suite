# Adds paypal ipn support.
#
class GmailSslSupport < ActiveRecord::Migration
  def self.up
    Preference.create(:name => 'use_smtp_tls_patch', :value => '0')
  end
  
  def self.down
    Preference.destroy_all("name = 'use_smtp_tls_patch'")
  end
end