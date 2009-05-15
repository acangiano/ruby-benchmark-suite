# Adds encryption support for cc & account #'s
#
class AddEncryptionSupport < ActiveRecord::Migration
  def self.up
    change_column :order_accounts, :cc_number, :string
    change_column :order_accounts, :account_number, :string
    # Crypt all existing cc's?
    OrderAccount.reset_column_information
    puts "Encrypting all stored CC numbers..."
    OrderAccount.find(:all).each do |oa|
      oa.set_unencrypted_number(oa.attributes['cc_number'], 'cc_number')
      oa.set_unencrypted_number(oa.attributes['account_number'], 'account_number')
      oa.save
    end
  end
  
  def self.down
    puts "Unencrypting all stored CC numbers..."
    OrderAccount.find(:all).each do |oa|
      oa.cc_number = oa.get_unencrypted_number('cc_number')
      oa.account_number = oa.get_unencrypted_number('account_number')
      oa.save
    end
    change_column :order_accounts, :cc_number, :string, :limit => 17
    change_column :order_accounts, :account_number, :string, :limit => 20
  end
end