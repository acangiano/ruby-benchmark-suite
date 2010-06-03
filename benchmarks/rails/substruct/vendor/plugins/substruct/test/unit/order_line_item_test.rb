$: << '.'
require File.dirname(__FILE__) + '/../test_helper'

class OrderLineItemTest < ActiveSupport::TestCase
  fixtures :orders, :items, :order_line_items


  # Test if a valid order line item can be created with success.
  def test_should_create_order_line_item
    a_towel = items(:towel)
    an_order_line_item = OrderLineItem.for_product(a_towel)
    
    assert_equal an_order_line_item.item, a_towel
    assert_equal an_order_line_item.name, a_towel.name
    assert_equal an_order_line_item.unit_price, a_towel.price
    # When created the quantity should be 1.
    assert_equal an_order_line_item.quantity, 1
    
    assert_equal an_order_line_item.total, a_towel.price * 1
    assert_equal an_order_line_item.product_id, a_towel.id
    assert_equal an_order_line_item.product, a_towel
    assert_equal an_order_line_item.code, a_towel.code
    assert_equal an_order_line_item.code, a_towel.code
    assert_equal an_order_line_item.name, a_towel.name
  
    assert an_order_line_item.save
  end
  

  # Test if an empty name will be returned if the item is nil.
  def test_should_return_empty_name
    an_order_line_item = OrderLineItem.new
    assert_equal an_order_line_item.name, ""
  end


  # Test if an order line item can be found with success.
  def test_should_find_order_line_item
    an_order_line_item_id = order_line_items(:santa_next_christmas_order_item_1).id
    assert_nothing_raised {
      OrderLineItem.find(an_order_line_item_id)
    }
  end

  # Test valid order_line_item quantities
  def test_order_line_item_quantity_is_postive
    a_towel = items(:towel)
    an_order_line_item = OrderLineItem.for_product(a_towel)
    an_order_line_item.quantity = -1;
    assert_raise(ActiveRecord::RecordInvalid) { 
      an_order_line_item.save!
    }
    an_order_line_item.quantity = 0
    assert_raise(ActiveRecord::RecordInvalid) {
      an_order_line_item.save!
    }
    an_order_line_item.quantity = 1
    assert_nothing_raised {
      an_order_line_item.save!
    }
  end

  # TODO: I think that all these methods should be protected.
  # Theres no much things to play with, as an order line item should only reflect an item,
  # and be manipulated through orders. 


end