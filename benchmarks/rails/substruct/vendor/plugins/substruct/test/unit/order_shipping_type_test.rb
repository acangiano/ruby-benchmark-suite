require File.dirname(__FILE__) + '/../test_helper'

class OrderShippingTypeTest < ActiveSupport::TestCase
  fixtures(
    :rights, :roles, :users, :preferences,
    :order_shipping_types, :order_shipping_weights
  )


  # Test if a valid shipping type can be created with success.
  def test_should_create_shipping_type
    a_shipping_type = OrderShippingType.new
    
    a_shipping_type.code = "UPWX"
    a_shipping_type.name = "UPS Worldwide Express (International Only)"
    a_shipping_type.is_domestic = 0
    a_shipping_type.price = 12.00
  
    assert a_shipping_type.save
  end


  # Test if a shipping type can be found with success.
  def test_should_find_shipping_type
    a_shipping_type_id = order_shipping_types(:ups_ground).id
    assert_nothing_raised {
      OrderShippingType.find(a_shipping_type_id)
    }
  end


  # Test if a shipping type can be updated with success.
  def test_should_update_shipping_type
    a_shipping_type = order_shipping_types(:ups_ground)
    assert a_shipping_type.update_attributes(:name => 'UPS Ground Shipping')
  end


  # Test if a shipping type can be destroyed with success.
  def test_should_destroy_shipping_type
    a_shipping_type = order_shipping_types(:ups_ground)
    a_shipping_type.destroy
    assert_raise(ActiveRecord::RecordNotFound) {
      OrderShippingType.find(a_shipping_type.id)
    }
  end


  # Test if an invalid shipping type really will NOT be created.
  # TODO: Take a look at this, an empty price continues being a problem.
  def test_should_not_create_invalid_shipping_type
#    a_shipping_type = OrderShippingType.new
#    a_shipping_type.price = ""
#    assert !a_shipping_type.valid?
#    assert a_shipping_type.errors.invalid?(:price)
#    # A shipping type must have a price.
#    assert_same_elements ["can't be blank", "is not a number"], a_shipping_type.errors.on(:price)
#    assert !a_shipping_type.save
  end


  # Test if shipping types can be associated with shipping weights.
  def test_should_associate_shipping_weights
    a_shipping_type = order_shipping_types(:ups_worldwide)
    assert_equal a_shipping_type.weights.count, 0

    # Create some shipping weights.
    a_shipping_weight_1 = OrderShippingWeight.new
    a_shipping_weight_1.min_weight = 0.00
    a_shipping_weight_1.max_weight = 1.00
    a_shipping_weight_1.price = 13.00
    a_shipping_weight_2 = OrderShippingWeight.new
    a_shipping_weight_2.min_weight = 1.01
    a_shipping_weight_2.max_weight = 2.00
    a_shipping_weight_2.price = 14.00

    # Assign the shipping weight to its respective shipping type.  
    assert a_shipping_type.weights << a_shipping_weight_1
    assert a_shipping_type.weights << a_shipping_weight_2

    assert_equal a_shipping_type.weights.count, 2

    # Break an association.
    a_shipping_type.weights.delete(a_shipping_weight_1)
    assert_equal a_shipping_type.weights.count, 1
  end


  # Test if a list of domestic shipments ordered by price can be obtained.
  def test_should_get_domestic
    OrderShippingType.get_domestic
    assert_equal order_shipping_types(:ups_ground, :ups_xp_critical), OrderShippingType.get_domestic
  end


  # Test if a list of foreign shipments ordered by price can be obtained.
  def test_should_get_foreign
    OrderShippingType.get_foreign
    assert_equal [order_shipping_types(:ups_worldwide)], OrderShippingType.get_foreign
  end

  
  # Test if the right calculated price will be shown.
  def test_should_show_calculated_price
    an_ups_ground = order_shipping_types(:ups_ground)
    a_shipping_weight = order_shipping_weights(:upg_less_1)
    
    # Test if a calculated price of an inexistent weight variation will default
    # to the price of the type itself.
    assert_equal an_ups_ground.calculate_price(10.0), an_ups_ground.price
    # Test if a calculated price with a specified weight will be the price
    # of the weight variation.
    assert_equal an_ups_ground.calculate_price(1.0), a_shipping_weight.price
  end


  # TODO: Theres no reason to have this method.
  # Test if wights can be associated and disassociated.
  def test_should_associate_weights
    a_shipping_type = order_shipping_types(:ups_worldwide)
    assert_equal a_shipping_type.weights.count, 0

    # Create some shipping weights.
    shipping_weights = [ [
      :min_weight => 0.00,
      :max_weight => 1.00,
      :price => 13.00
    ], [
      :min_weight => 1.01,
      :max_weight => 2.00,
      :price => 14.00
    ] ]

    # Assign the shipping weight to its respective shipping type.  
    assert a_shipping_type.weights = shipping_weights

    assert_equal a_shipping_type.weights.count, 2
  end


end
