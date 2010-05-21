$: << '.'
require File.dirname(__FILE__) + '/../test_helper'

class OrderUserTest < ActiveSupport::TestCase
  fixtures :order_users, :orders, :items


  # Test if a valid order user can be created with success.
  def test_should_create_order_user
    an_order_user = OrderUser.new(
      :username => "",
      :email_address => "arthur.dent@whoknowswhere.com",
      :password => "arthur",
      :first_name => "",
      :last_name => ""
    )
  
    assert an_order_user.save
  end


  # Test if a valid order user can be created with success and a password will be
  # generated if nil.
  def test_should_create_order_user_and_generate_password
    an_order_user = OrderUser.new(
      :username => "",
      :email_address => "arthur.dent@whoknowswhere.com",
      :first_name => "",
      :last_name => ""
    )
  
    assert an_order_user.save
    assert !OrderUser.find_by_email_address("arthur.dent@whoknowswhere.com").password.empty?
  end
  
  
  # Test if a valid order user can be created with success and a password will be
  # generated if empty.
  def test_should_create_order_user_and_generate_password
    an_order_user = OrderUser.new(
      :username => "",
      :email_address => "arthur.dent@whoknowswhere.com",
      :password => "",
      :first_name => "",
      :last_name => ""
    )
  
    assert an_order_user.save
    assert !OrderUser.find_by_email_address("arthur.dent@whoknowswhere.com").password.empty?
  end

  
  # Test if an order user can be found with success.
  def test_should_find_order_user
    an_order_user_id = order_users(:santa).id
    assert_nothing_raised {
      OrderUser.find(an_order_user_id)
    }
  end


  # Test if an order user can be updated with success.
  def test_should_update_order_user
    an_order_user = order_users(:santa)
    assert an_order_user.update_attributes(
      :email_address => 'santa@whoknowswhere.com'
    )
  end


  # Test if an order user can be destroyed with success.
  def test_should_destroy_order_user
    an_order_user = order_users(:santa)
    an_order_user.destroy
    assert_raise(ActiveRecord::RecordNotFound) {
      OrderUser.find(an_order_user.id)
    }
  end


  # Test if an invalid order user really will NOT be created.
  def test_should_not_create_invalid_order_user
    an_order_user = OrderUser.new(
      :username => "",
      :email_address => "",
      :password => "arthur",
      :first_name => "",
      :last_name => ""
    )

    # An order user must have an email address.
    assert !an_order_user.valid?
    assert an_order_user.errors.invalid?(:email_address)
    assert_same_elements ["Please fill in this field.", "Please enter a valid email address."], an_order_user.errors.on(:email_address)

    # An order user must have a valid email address.
    an_order_user.email_address = "arthur.dent"
    assert !an_order_user.valid?
    assert an_order_user.errors.invalid?(:email_address)
    assert_equal "Please enter a valid email address.", an_order_user.errors.on(:email_address)

    # An order user must have an unique email address.
    an_order_user.email_address = "santa.claus@whoknowswhere.com"
    assert !an_order_user.valid?
    assert an_order_user.errors.invalid?(:email_address)
    assert_equal "\n\t    This email address has already been taken in our system.<br/>\n\t    If you have already ordered with us, please login.\n\t  ", an_order_user.errors.on(:email_address)

    # An order user must have an email address shorter than 255 characters.
    an_order_user.email_address = "my_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_email_address"
    assert !an_order_user.valid?
    assert an_order_user.errors.invalid?(:email_address)
    assert_same_elements ["Please enter a valid email address.", "is too long (maximum is 255 characters)"], an_order_user.errors.on(:email_address)

    assert !an_order_user.save
  end


  # Test if an order user can be authenticated.
  def test_should_authenticate_order_user
    an_order_user = order_users(:santa)
    
    assert_equal an_order_user, OrderUser.authenticate("santa.claus@whoknowswhere.com", "santa")
    assert_equal an_order_user, OrderUser.authenticate("santa.claus@whoknowswhere.com", an_order_user.last_order.order_number)
    assert OrderUser.authenticate?("santa.claus@whoknowswhere.com", "santa")
  end
  
  
  # Test if an order user with a wrong password will NOT be authenticated.
  def test_should_not_authenticate_order_user
    assert_equal nil, OrderUser.authenticate("santa.claus@whoknowswhere.com", "wrongpassword")
    assert !OrderUser.authenticate?("santa.claus@whoknowswhere.com", "wrongpassword")
  end
  
  
  # Test if we can find the last billing address.
  def test_should_return_last_billing_address
    an_order_user = order_users(:santa)
    assert_equal an_order_user.last_order.billing_address, an_order_user.last_billing_address
    assert_equal an_order_user.billing_address, an_order_user.last_billing_address

    another_order_user = order_users(:mustard)
    assert_equal nil, another_order_user.last_billing_address
    assert_equal an_order_user.billing_address, an_order_user.last_billing_address
  end
  
  
  # Test if we can find the last shipping address.
  def test_should_return_last_shipping_address
    an_order_user = order_users(:santa)
    assert_equal an_order_user.last_order.shipping_address, an_order_user.last_shipping_address
    assert_equal an_order_user.shipping_address, an_order_user.last_shipping_address

    another_order_user = order_users(:mustard)
    assert_equal nil, another_order_user.last_shipping_address
    assert_equal an_order_user.shipping_address, an_order_user.last_shipping_address
  end


  # Test if we can find the last order account address.
  def test_should_return_last_order_account
    an_order_user = order_users(:santa)
    assert_equal an_order_user.last_order.order_account, an_order_user.last_order_account
    assert_equal an_order_user.order_account, an_order_user.last_order_account

    another_order_user = order_users(:mustard)
    assert_equal nil, another_order_user.last_order_account
    assert_equal an_order_user.order_account, an_order_user.last_order_account
  end


  # Test if the password can be reseted.
  def test_should_reset_password
    # Setup the mailer.
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    initial_mbox_length = ActionMailer::Base.deliveries.length

    an_order_user = order_users(:santa)
    old_password = an_order_user.password
    
    an_order_user.reset_password
    new_password = an_order_user.password

    assert_equal new_password.length, 8
    assert_not_equal old_password, new_password
    
    # We should have received a mail about that.
    assert_equal ActionMailer::Base.deliveries.length, initial_mbox_length + 1
  end
  
  
  # TODO: Theres no need to have these methods.
  # Test if we can add and remove items from wishlist.
  def test_should_add_and_remove_items_from_wishlist
    # Load an user and some products.
    an_order_user = order_users(:mustard)
    a_towel = items(:towel)
    a_stuff = items(:the_stuff)

    assert_equal an_order_user.items.count, 0
    an_order_user.add_item_to_wishlist(a_towel)
    an_order_user.add_item_to_wishlist(a_stuff)
    assert_equal an_order_user.items.count, 2
    an_order_user.remove_item_from_wishlist(a_towel)
    an_order_user.remove_item_from_wishlist(a_stuff)
    assert_equal an_order_user.items.count, 0

    # Try to remove an item that isnt there anymore.
    assert !an_order_user.remove_item_from_wishlist(a_stuff)
end
  
  
end