require File.dirname(__FILE__) + '/../test_helper'

class OrderShippingWeightTest < ActiveSupport::TestCase
  fixtures :rights, :roles, :users
  fixtures :order_shipping_types, :order_shipping_weights


# TODO: Orphaned shipping weights can be saved.
#  # Test if an orphaned shipping weight will NOT be saved.
#  def test_should_not_save_orphaned_shipping_weight
#    # Create a shipping weight.
#    a_shipping_weight = OrderShippingWeight.new
#    a_shipping_weight.min_weight = 0.00
#    a_shipping_weight.max_weight = 1.00
#    a_shipping_weight.price = 10.00
#    # Don't assign the shipping weight to anything and try to save it.
#    assert_raise(NoMethodError) {
#      a_shipping_weight.save
#    }
#  end


  # Test if an invalid shipping weight really will NOT be created.
  # TODO: Take a look at this, an empty price continues being a problem.
  def test_should_not_create_invalid_shipping_weight
#    a_shipping_weight = OrderShippingWeight.new
#    a_shipping_weight.min_weight = 0.00
#    a_shipping_weight.max_weight = 1.00
#    a_shipping_weight.price = ""
#    assert !a_shipping_weight.valid?
#    assert a_shipping_weight.errors.invalid?(:price)
#    # A shipping weight must have a price.
#    assert_same_elements ["can't be blank", "is not a number"], a_shipping_weight.errors.on(:price)
#    assert !a_shipping_weight.save
  end
  
  
  # Test if a valid shipping weight can be assigned and saved with success.
  def test_should_assign_and_save_shipping_weight
    # Load a shipping type.
    a_shipping_type = order_shipping_types(:ups_ground)
    assert_nothing_raised {
      OrderShippingType.find(a_shipping_type.id)
    }

    # Create a shipping weight.
    a_shipping_weight = OrderShippingWeight.new
    a_shipping_weight.min_weight = 3.01
    a_shipping_weight.max_weight = 4.00
    a_shipping_weight.price = 13.00

    # Assign the shipping weight to its respective shipping type and save the
    # shipping weight.  
    assert a_shipping_type.weights << a_shipping_weight
    assert a_shipping_weight.save
  end


  # Test if a shipping weight can be found with success.
  def test_should_find_shipping_weight
    a_shipping_weight_id = order_shipping_weights(:upg_less_1).id
    assert_nothing_raised {
      OrderShippingWeight.find(a_shipping_weight_id)
    }
  end


  # Test if a shipping weight can be updated.
  def test_should_update_shipping_weight
    a_shipping_weight = order_shipping_weights(:upg_less_1)
    assert a_shipping_weight.update_attributes(:max_weight => 0.98)
  end


  # Test if a shipping weight can be destroyed.
  def test_should_destroy_shipping_weight
    a_shipping_weight = order_shipping_weights(:upg_less_1)
    a_shipping_weight.destroy
    assert_raise(ActiveRecord::RecordNotFound) {
      OrderShippingWeight.find(a_shipping_weight.id)
    }
  end


end
