# OrderUser aka Customer
#
# This is what ties all orders / addresses / wishlist items
# together for a customer. Lets them login, etc.
#
#
class OrderUser < ActiveRecord::Base
  has_many :orders,
	  :dependent => :nullify,
    :order => "created_on DESC"
	has_one :last_order,
	  :class_name => "Order",
	  :order => "created_on DESC"
	
	has_many :order_addresses, :dependent => :destroy
	has_many :order_accounts, :dependent => :destroy
	
  has_many :wishlist_items, 
    :dependent => :destroy,
    :order => "created_on DESC"
  has_many :items, :through => :wishlist_items,
    :order => "wishlist_items.created_on DESC"
  
  validates_presence_of :email_address, :message => ERROR_EMPTY
	validates_length_of :email_address, :maximum => 255
	validates_uniqueness_of :email_address, 
	  :message => %q/
	    This email address has already been taken in our system.<br\/>
	    If you have already ordered with us, please login.
	  /
	validates_format_of :email_address,
	                    :with => /^([^@\s]+)@((?:[-a-zA-Z0-9]+\.)+[a-zA-Z]{2,})$/,
	                    :message => "Please enter a valid email address."

                      
  # We don't save passwords all the time when creating an account.
  # Generate one before save if a new record
  before_create :fill_password
  def fill_password
    if self.password.blank?
      self.password = OrderUser.generate_password()
    end
  end

                          
  #############################################################################
  # CLASS METHODS
  #############################################################################
               
  # Authenticate a customer.
  #
  # Example:
  #   @user = User.authenticate('bob', 'bobpass')
  #
  def self.authenticate(email, password)
    user = find(
      :first,
      :conditions => ["email_address = ?", email]
    )
    
    return nil if !user
    
    if !password.blank? && user.password == password
      return user
    elsif user.orders.find_by_order_number(password)
      return user
    else
      return nil
    end
  end

  def self.authenticate?(email, password)
    user = self.authenticate(email, password)
    if !user.nil? && user.email_address == email
      return true
    else
      false
    end
  end
  
	# Generates a random password
  #
  def self.generate_password(size = 8)
    chars = (('a'..'z').to_a + ('0'..'9').to_a) - %w(i o 0 1 l 0)
    (1..size).collect{|a| chars[rand(chars.size)] }.join
  end
  
  #############################################################################
  # INSTANCE METHODS 
  #############################################################################
  
  # Gets the last used billing address for this user.
  #
  def last_billing_address
    if !self.last_order
      return nil
    else
      return self.last_order.billing_address
    end
  end
  def billing_address
    self.last_billing_address
	end
	
	# Last used shipping address
	def last_shipping_address
    if !self.last_order
      return nil
    else
      return self.last_order.shipping_address
    end
  end
	def shipping_address
	  self.last_shipping_address
	end
	
	# Last used account
	def last_order_account
	  if !self.last_order
	    return nil
	  else
	    return self.last_order.order_account
	  end
  end
	def order_account
	  self.last_order_account
	end
  
  # Resets password & emails client
  #
  def reset_password 
    self.update_attribute('password', OrderUser.generate_password())
    email = OrdersMailer.deliver_reset_password(self)
  end
  
  # Adds an item to this customer's wishlist
  def add_item_to_wishlist(item)
    self.items << item if !self.items.include?(item)
  end
  
  # Removes item from wishlist
  def remove_item_from_wishlist(item)
    if wishlist_item = self.wishlist_items.find_by_item_id(item.id)
      wishlist_item.destroy
      return true
    else
      return false
    end
  end
	
end
