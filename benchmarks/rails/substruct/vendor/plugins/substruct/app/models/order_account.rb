class OrderAccount < ActiveRecord::Base
  require 'ezcrypto'
  
  # PROPERTIES ================================================================
  
  @@salt = 'salt_$alt_salt'
  cattr_accessor :salt
  @@password = '$ub$truct_change_me'
  cattr_accessor :password
  
  attr_protected :order_user_id
  
  TYPES = {
    'Credit Card' => 1,
    'Checking' => 2,
    'Savings' => 3,
    'Business Checking' => 4,
    'PayPal' => 5
  }
  
  # Associations
  has_one :order_account_type
  has_one :order
  belongs_to :order_user
  
  
  # VALIDATION ================================================================
  
  validates_presence_of :order_user_id
  
  validates_presence_of :cc_number,
    :if => Proc.new { |oa| oa.order_account_type_id == TYPES['Credit Card'] },
    :message => ERROR_EMPTY
  
  validates_presence_of :routing_number,
    :if => Proc.new { |oa| oa.order_account_type_id == TYPES['Checking'] || oa.order_account_type_id == TYPES['Business Checking'] },
    :message => ERROR_EMPTY
  
  validates_presence_of :account_number,
    :if => Proc.new { |oa| oa.order_account_type_id == TYPES['Checking'] || oa.order_account_type_id == TYPES['Business Checking'] },
    :message => ERROR_EMPTY
  
  validates_format_of :credit_ccv, :with => /^[\d]*$/, :message => ERROR_NUMBER
  validates_numericality_of :expiration_month, :expiration_year

  # Make sure expiration date is ok.
  def validate
    today = DateTime.now
    begin
      if (
        (today.month > self.expiration_month && today.year >= self.expiration_year) ||
        (today.year > self.expiration_year)
      )
        errors.add(:expiration_month, 'Please enter a valid expiration date.')
      end
    rescue
      errors.add(:expiration_month, 'Please enter a valid expiration date.')
    end
  end

  # CLASS METHODS =============================================================

  # List of months for dropdown in UI
  def self.months
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
  end

  # List of years for dropdown in UI
  def self.years
    start_year = Date.today.year
    years = Array.new
    10.times do
      years << start_year
      start_year += 1
    end
    return years
  end

  # INSTANCE METHODS ==========================================================

public
  # Obfuscates personal information about this account
  # - CC number
  def clear_personal_information
    new_number = self.cc_number_last_four
    self.cc_number = new_number
    self.save
    # Return number in case we need it
    return new_number
  end
  
  # Setter for cc number.
  # Crypts before it saves.
  #
  def cc_number=(number='')
    self.set_unencrypted_number(number, 'cc_number')
  end
  def cc_number
    self.get_unencrypted_number('cc_number')
  end
  
  def cc_number_last_four
    if !self.cc_number.blank? && self.cc_number.size > 4
      number = String.new(self.cc_number)
      # How many spaces to replace with X's
      spaces_to_pad = number.length-4
      # Cut string
      new_number = number[spaces_to_pad,number.length]
      # Pad with X's
      return new_number.rjust(number.length, 'X')
    end
  end
  
  # Setter for account number.
  # Crypts before it saves.
  #
  def account_number=(number='')
    self.set_unencrypted_number(number, 'account_number')
  end
  def account_number
    self.get_unencrypted_number('account_number')
  end

  # Gets an unencrypted # from the db.
  #
  def get_unencrypted_number(attribute)
    key = EzCrypto::Key.with_password(@@password, @@salt)
    # For blanks this can throw a "wrong final block length" error.
    begin
      value = self[attribute.to_sym]
      return key.decrypt64(value)
    rescue
      nil
    end
  end
  
  # Crypts & sets unencrypted number to db.
  # This would probably be best as a plugin...but maybe later.
  # acts_as_crypted_number ?
  def set_unencrypted_number(number='', attribute='')
    return if attribute.empty?
    key = EzCrypto::Key.with_password(@@password, @@salt)
    begin
      self[attribute.to_sym] = key.encrypt64(number)
    rescue
      self[attribute.to_sym] = ''
    end
  end

end
