$: << '.'
require File.dirname(__FILE__) + '/../test_helper'

class OrdersMailerTest < ActiveSupport::TestCase
  fixtures :orders, :order_line_items, :order_addresses, :order_users, :order_shipping_types, :items
  fixtures :order_accounts, :order_status_codes, :countries, :promotions, :preferences


  # Setup how mail should be delivered in tests.
  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end


  # Test a mail delivery when success.
  def test_receipt
    initial_mbox_length = ActionMailer::Base.deliveries.length
    # Get any order.
    an_order = orders(:santa_next_christmas_order)
    
    # Create a standard success response. Parameters: success, message, params = {}, options = {}
    a_positive_response = ActiveMerchant::Billing::Response.new(
      true,
      "(TESTMODE) This transaction has been approved",
      {
        :response_reason_text => "(TESTMODE) This transaction has been approved.",
        :response_reason_code => "1",
        :response_code => "1",
        :avs_message => "Address verification not applicable for this transaction",
        :transaction_id => "0",
        :avs_result_code => "P",
        :card_code => nil
     }, {
        :test => true,
        :authorization => "0",
        :fraud_review => false
      }
    )
    
    # Stub the purchase method to not call home (using commit) and return a standard success response.
    ActiveMerchant::Billing::AuthorizeNetGateway.any_instance.stubs(:purchase).returns(a_positive_response)

    # Assert that with a success response the method will return true.
    assert_equal an_order.run_transaction_authorize, true
   
    receipt_body = ContentNode.find(:first, :conditions => ["name = ?", 'OrderReceipt'])

    response_mail = OrdersMailer.create_receipt(an_order, receipt_body.content)
    
    assert_equal response_mail.subject, "Thank you for your order! (\##{an_order.order_number})"
    assert_match /Order #: #{an_order.order_number}/, response_mail.body
    assert_equal response_mail.to.to_a, [an_order.order_user.email_address]
    
    assert_equal ActionMailer::Base.deliveries.length, initial_mbox_length + 1
  end

  
  # Test a mail delivery when failed.
  def test_failed
    initial_mbox_length = ActionMailer::Base.deliveries.length
    # Get any order.
    an_order = orders(:santa_next_christmas_order)
    
    # Create a standard failure response when cc number is wrong. Parameters: success, message, params = {}, options = {}
    a_negative_response = ActiveMerchant::Billing::Response.new(
      false,
      "(TESTMODE) The credit card number is invalid",
      {
        :response_reason_text => "(TESTMODE) The credit card number is invalid.",
        :response_reason_code => "6",
        :response_code => "3",
        :avs_message => "Address verification not applicable for this transaction",
        :transaction_id => "0",
        :avs_result_code => "P",
        :card_code => nil
     }, {
        :test => true,
        :authorization => "0",
        :fraud_review => false
      }
    )
    
    # Stub the purchase method to not call home (using commit) and return a standard failure response.
    ActiveMerchant::Billing::AuthorizeNetGateway.any_instance.stubs(:purchase).returns(a_negative_response)

    # Assert that with a failure response the method will return the response message.
    assert_equal an_order.run_transaction_authorize, a_negative_response.message
   
    response_mail = OrdersMailer.create_failed(an_order)
    
    assert_equal response_mail.subject, 'An order has failed on the site'
    assert_match /Order #: #{an_order.order_number}/, response_mail.body
    assert_equal response_mail.to.to_a, Preference.find_by_name('mail_copy_to').value.split(',')
    
    assert_equal ActionMailer::Base.deliveries.length, initial_mbox_length + 1
  end


  # Test a mail delivery when the password is reseted.
  def dont_test_reset_password
    initial_mbox_length = ActionMailer::Base.deliveries.length

    # Get an user to reset the password. 
    an_order_user = order_users(:santa)
    
    response_mail = OrdersMailer.create_reset_password(an_order_user)

    assert_equal response_mail.subject, "Password reset for #{Preference.find_by_name('store_name').value}"
    assert_match /Your password has been reset/, response_mail.body
    assert_equal response_mail.to.to_a, [an_order_user.email_address]

    # We should have received a mail about that.
    assert_equal ActionMailer::Base.deliveries.length, initial_mbox_length + 1
  end


end