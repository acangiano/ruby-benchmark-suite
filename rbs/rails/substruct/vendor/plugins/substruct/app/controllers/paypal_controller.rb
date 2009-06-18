class PaypalController < ApplicationController
  include ActiveMerchant::Billing::Integrations

  # Handles Instant Payment Notification
  # from PayPal after a purchase.
  #
  def ipn
    notification = Paypal::Notification.new(request.raw_post)
    order = Order.find_by_order_number(
      notification.invoice,
      :include => :shipping_address
    )

    if notification.acknowledge
      begin
        if notification.complete? && 
          Order.matches_ipn(notification, order, params) 
          Order.pass_ipn(order, params[:txn_id])
        else
          Order.fail_ipn(order)
        end
      rescue => e
        order.order_status_code_id = 3
        order.save
        raise
      ensure
        order.save
      end
    end
    
    render :nothing => true
  end
end
