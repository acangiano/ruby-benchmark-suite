require_dependency 'order'
require_dependency 'order_address'
require_dependency 'order_account'
require_dependency 'order_user'

# OrderHelper helps controllers in the application CrUD orders.
#
# It's used as a mixin for various controllers.
module OrderHelper

  # Create all of these instance variables that are associated with an order
  # If a customer is already logged in, use that info.
  #
  def initialize_new_order
    if @customer
      @order_user = @customer
      @billing_address = @customer.last_billing_address || OrderAddress.new
      @shipping_address = @customer.last_shipping_address || OrderAddress.new
      @use_separate_shipping_address = @billing_address != @shipping_address
    else
      @order_user = OrderUser.new
      @billing_address = OrderAddress.new
      @shipping_address = OrderAddress.new      
      @use_separate_shipping_address = false
    end

    @order_account = OrderAccount.new
    @order_account.order_account_type_id = OrderAccount::TYPES['Credit Card']
  end

  def initialize_existing_order
    if @customer
      logger.info('Order user is @customer')
      @order_user = @customer
      @billing_address = @customer.last_billing_address || OrderAddress.new
      @shipping_address = @customer.last_shipping_address || OrderAddress.new
      @use_separate_shipping_address = @billing_address != @shipping_address
    else
      logger.info('Order user coming from @order')
      @order_user = @order.order_user
      @billing_address = @order.billing_address
      @shipping_address = @order.shipping_address
      @use_separate_shipping_address = false
    end
    @order_account = @order.account
  end

  # Does a creation of all required objects from a form post
  #
  # Each model is created and validated at the beginning.
  # This assures all errors show up if even if the begin...rescue...end
  # block skips save! of a model.
  #
  # Does transaction to create a new order.
  #
  # Will throw an exception if there is a problem, so be sure to handle that
  def create_order_from_post
    @use_separate_shipping_address = params[:use_separate_shipping_address]

    @order_user = OrderUser.find_or_create_by_email_address(
      params[:order_user][:email_address]
    )
    @order_user.valid?

    @order.attributes = params[:order]
    @order.valid?

    # Look up billing address and update if customer is logged in.
    @billing_address = OrderAddress.new(params[:billing_address])
    @shipping_address = OrderAddress.new(params[:shipping_address])

    @billing_address.valid?
    
    if @use_separate_shipping_address
      @shipping_address.valid?
    end

    unless Order.get_cc_processor == Preference::CC_PROCESSORS[1]
      @order_account = OrderAccount.new(params[:order_account])
    else
      # PayPal is collecting the credit card info, so stuff a bogus one
      # here so we can get on with it.
      @order_account = OrderAccount.new({
        :cc_number => '00000000000000000',
        :expiration_month => '12',
				:expiration_year => '3000'
			})
    end
    @order_account.valid? 

    OrderUser.transaction do
      @order_user.save!
      Order.transaction do
        @order.attributes = params[:order]
        @order.order_user = @order_user
        @order.save!
      end
      OrderAddress.transaction do
        # Addresses
        @billing_address = @order_user.order_addresses.create(params[:billing_address])
        @billing_address.save!
        @order.update_attributes({
          :billing_address_id => @billing_address.id,
          :shipping_address_id => @billing_address.id
        })
        if @use_separate_shipping_address
          @shipping_address = @order_user.order_addresses.create(params[:shipping_address])
          @shipping_address.save!
          @order.update_attribute('shipping_address_id', @shipping_address.id)
        end
      end
      OrderAccount.transaction do
        @order_account.order_user_id = @order_user.id
        @order_account.save!
        @order.update_attribute('order_account_id', @order_account.id)
      end
    end
  end

  # Updates an order from a post.
  # Used for editing orders on the admin side & the customer side.
  #
  # On the admin side we trust the ID fields from the post
  # On the customer side, we use the order id in session to identify order.
  # (@order should be set before calling this method)
  def update_order_from_post
    logger.info
    logger.info "UPDATING ORDER FROM POST"
    logger.info params[:order_account].inspect
    logger.info
    # Find the objects in the db to update
		@order_user = @order.order_user
		@order_account = @order.account
		@billing_address = @order.billing_address
		# Comes in as a string, so we force it into a boolean.
		@use_separate_shipping_address = (params[:use_separate_shipping_address] == 'true')
		# Update all objects
		# Store the results in variables that we use from our controller.
		@order.update_attributes!(params[:order])
		@order_user.update_attributes!(params[:order_user])
		@order_account.update_attributes!(params[:order_account])
		@billing_address.update_attributes!(params[:billing_address])
		if (@use_separate_shipping_address)
		  # Create a new record for shipping address if it's the same
		  # as the billing address...or if it doesn't exist.
			@shipping_address = @order.shipping_address
		  if @billing_address == @shipping_address || @shipping_address.nil?
		    @shipping_address = @order_user.order_addresses.create(params[:shipping_address])
		    @order.shipping_address_id = @shipping_address.id
		    @order.save!
		  else
		    @shipping_address.update_attributes!(params[:shipping_address])
      end
		else
			@shipping_address = OrderAddress.new
		end
  end

end
