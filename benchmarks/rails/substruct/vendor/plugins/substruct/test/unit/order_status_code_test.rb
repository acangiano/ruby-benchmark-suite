$: << '.'
require File.dirname(__FILE__) + '/../test_helper'

class OrderStatusCodeTest < ActiveSupport::TestCase
  fixtures :order_status_codes


  # Test if the right status codes will be shown as editable.
  def test_should_show_if_it_is_editable
    # These should.
    assert order_status_codes(:cart).is_editable?
    assert order_status_codes(:to_charge).is_editable?
    assert order_status_codes(:on_hold_payment_failed).is_editable?
    assert order_status_codes(:on_hold_awaiting_payment).is_editable?
    assert order_status_codes(:ordered_paid_to_ship).is_editable?
    # These should NOT.
    assert !order_status_codes(:ordered_paid_shipped).is_editable?
    assert !order_status_codes(:sent_to_fulfillment).is_editable?
    assert !order_status_codes(:cancelled).is_editable?
    assert !order_status_codes(:returned).is_editable?
  end


end