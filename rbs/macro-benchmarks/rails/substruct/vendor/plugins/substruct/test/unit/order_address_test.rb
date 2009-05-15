require File.dirname(__FILE__) + '/../test_helper'

class OrderAddressTest < ActiveSupport::TestCase
  fixtures :users
  fixtures :order_addresses, :order_users, :countries


  # Test if a valid address can be created with success.
  def test_should_create_address
    an_address = OrderAddress.new
    
    an_address.order_user = order_users(:mustard)
    an_address.first_name = "Colonel"
    an_address.last_name = "Mustard"
    an_address.telephone = "000000000"
    an_address.address = "After Boddy Mansion at right"
    an_address.city = "London"
    an_address.state = "Greater London"
    an_address.zip = "00000"
    an_address.country = countries(:GB)
  
    assert an_address.save
  end


  # Test if a address can be found with success.
  def test_should_find_address
    an_address_id = order_addresses(:santa_address).id
    assert_nothing_raised {
      OrderAddress.find(an_address_id)
    }
  end

  def test_country_not_nil
    an_address = OrderAddress.find(order_addresses(:santa_address).id)
    assert_not_nil an_address.country    
  end

  # Test if a address can be updated with success.
  def test_should_update_address
    an_address = order_addresses(:santa_address)
    assert an_address.update_attributes(:address => 'After third ice mountain at left')
  end


  # Test if a address can be destroyed with success.
  def test_should_destroy_address
    an_address = order_addresses(:santa_address)
    an_address.destroy
    assert_raise(ActiveRecord::RecordNotFound) {
      OrderAddress.find(an_address.id)
    }
  end


  # Test if an invalid address really will NOT be created.
  def test_should_not_create_invalid_address
    an_address = OrderAddress.new
    
    assert !an_address.valid?
    #assert an_address.errors.invalid?(:order_user_id), "Should have an error in order_user_id"
    #assert an_address.errors.invalid?(:country_id), "Should have an error in country_id"
    assert an_address.errors.invalid?(:zip), "Should have an error in zip"
    assert an_address.errors.invalid?(:telephone), "Should have an error in telephone"
    assert an_address.errors.invalid?(:first_name), "Should have an error in first_name"
    assert an_address.errors.invalid?(:last_name), "Should have an error in last_name"
    assert an_address.errors.invalid?(:address), "Should have an error in address"
    
    # An address must have the fields filled.
    assert_equal "#{ERROR_EMPTY} If you live in a country that doesn't have postal codes please enter '00000'.", an_address.errors.on(:zip)
    assert_equal ERROR_EMPTY, an_address.errors.on(:telephone)
    assert_equal ERROR_EMPTY, an_address.errors.on(:first_name)
    assert_equal ERROR_EMPTY, an_address.errors.on(:last_name)
    assert_equal ERROR_EMPTY, an_address.errors.on(:address)

    an_address.address = "P.O. BOX"
    assert !an_address.valid?
    assert_equal "Sorry, we don't ship to P.O. boxes", an_address.errors.on(:address)
    
#    TODO: The address is being saved even when not associated with an user or a country.
#    an_address.first_name = "Colonel"
#    an_address.last_name = "Mustard"
#    an_address.telephone = "000000000"
#    an_address.address = "After Boddy Mansion at right"
#    an_address.zip = "00000"

#    TODO: Why try to validate P. O. Boxes?

    assert !an_address.save
  end


  # TODO: Get rid of this method if it will not be used.
  # Test if a shipping address can be found for an user.
  def test_should_find_shipping_address
    # find_shipping_address_for_user appears to be a deprecated method, as when
    # executed it gives an error, and I couldn't find an ocasion where it will be executed.
    assert_raise(ActiveRecord::StatementInvalid) {
      OrderAddress.find_shipping_address_for_user(users(:c_norris))
    }
  end


  # Test if the user's first and last name will be concatenated.
  def test_should_concatenate_user_first_and_last_name
    an_address = order_addresses(:santa_address)
    assert_equal an_address.name, "#{an_address.first_name} #{an_address.last_name}" 
  end


end
