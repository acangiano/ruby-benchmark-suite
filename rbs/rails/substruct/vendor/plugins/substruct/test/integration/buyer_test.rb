require File.dirname(__FILE__) + '/../test_helper'

class BuyerTest < ActionController::IntegrationTest
  fixtures :all
  
  def setup
    @santa_address = OrderAddress.find(order_addresses(:santa_address).id)
  end
  
  def post_valid_order
    post(
      'store/checkout',
      :order_account => {
        :cc_number => "4007000000027",
        :expiration_year => 4.years.from_now.year,
        :expiration_month => "1"
      },
      :shipping_address => @santa_address.attributes,
      :billing_address => @santa_address.attributes,
      :order_user => {
        :email_address => "uncle.scrooge@whoknowswhere.com"
      },
      :use_separate_shipping_address => "false"
    )
  end

  def test_should_buy_something
    # LOGIN TO THE SYSTEM
    a_customer = order_users(:santa)

    get 'customers/login'
    assert_response :success
    assert_equal assigns(:title), "Customer Login"
    assert_template 'login'
    
    post 'customers/login', :modal => "", :login => "santa.claus@whoknowswhere.com", :password => "santa"
    # If loged in we should be redirected to orders. 
    assert_response :redirect
    assert_redirected_to :action => :orders
    
    # We need to follow the redirect.
    follow_redirect!
    assert_select "p", :text => /Login successful/

    # Assert the customer id is in the session.
    assert_equal session[:customer], a_customer.id

    # ADD 1 PRODUCT TO THE CART

    # Try adding a product.
    a_product = items(:towel)
    post 'store/add_to_cart_ajax', :id => a_product.id
    # Here nothing is rendered directly, but a showPopWin() javascript function is executed.
    a_cart = assigns(:order)
    assert_equal a_cart.items.length, 1
    
    # CHECKOUT AND FOLLOW
    
    get 'store/checkout'
    assert_response :success
    assert_template 'checkout'
    assert_equal assigns(:title), "Please enter your information to continue this purchase."
    assert_not_nil assigns(:cc_processor)
    
    ###################
    a_cart = assigns(:order)
    assert_equal a_cart.items.first.quantity, 1, "UNEXPECTED FIRST CART ITEM QUANTITY"
    ###################

    # Post to it an order.
    post_valid_order()
    
    assert_response :redirect
    assert_redirected_to :action => :select_shipping_method

    ###################
    an_order = assigns(:order)
    assert_equal an_order.items.first.quantity, 1, "UNEXPECTED FIRST ORDER ITEM QUANTITY AFTER CHECKOUT"
    ###################

    follow_redirect!

    # Verify is was followed.
    assert_response :success
    assert_template 'select_shipping_method'
    assert_equal assigns(:title), "Select Your Shipping Method - Step 2 of 3"
    assert_not_nil assigns(:default_price)
    
    # SET THE SHIPPING METHOD AND FOLLOW
    
    # Post to it when the show confirmation preference is true.
    assert Preference.save_settings({ "store_show_confirmation" => "1" })
    post 'store/set_shipping_method', :ship_type_id => order_shipping_types(:ups_ground).id
    assert_response :redirect
    assert_redirected_to :action => :confirm_order

    ###################
    an_order = assigns(:order)
    assert_equal an_order.items.first.quantity, 1, "UNEXPECTED FIRST ORDER ITEM QUANTITY AFTER SHIPPING"
    ###################

    follow_redirect!

    # Verify is was followed.
    assert_template 'confirm_order'
    assert_equal assigns(:title), "Please confirm your order. - Step 3 of 3"
    
    # SECOND INTERACTION

    # ADD 1 MORE PRODUCT TO THE CART

    # Try adding a product.
    a_product = items(:towel)
    post 'store/add_to_cart_ajax', :id => a_product.id
    # Here nothing is rendered directly, but a showPopWin() javascript function is executed.
    a_cart = assigns(:order)
    assert_equal a_cart.items.length, 1
    
    ###################
    a_cart = assigns(:order)
    assert_equal a_cart.items.first.quantity, 2, "UNEXPECTED SECOND CART ITEM QUANTITY"
    ###################

    # CHECKOUT THE SECOND TIME AND FOLLOW
    
    get 'store/checkout'
    assert_response :success
    assert_template 'checkout'
    assert_equal assigns(:title), "Please enter your information to continue this purchase."
    assert_not_nil assigns(:cc_processor)
    
    # Post to it an order.
    post_valid_order()
    
    ###################
    a_cart = assigns(:order)
    assert_equal a_cart.items.first.quantity, 2, "UNEXPECTED SECOND CART ITEM QUANTITY AFTER CHECKOUT"
    ###################
    an_order = assigns(:order)
    assert_equal an_order.items.first.quantity, 2, "UNEXPECTED SECOND ORDER ITEM QUANTITY AFTER CHECKOUT"
    ###################

    assert_response :redirect
    assert_redirected_to :action => :select_shipping_method

    follow_redirect!
    
    # Verify is was followed.
    assert_response :success
    assert_template 'select_shipping_method'
    assert_equal assigns(:title), "Select Your Shipping Method - Step 2 of 3"
    assert_not_nil assigns(:default_price)
        
    # SET THE SHIPPING METHOD THE SECOND TIME AND FOLLOW
    
    # Post to it when the show confirmation preference is true.
    assert Preference.save_settings({ "store_show_confirmation" => "1" })
    post 'store/set_shipping_method', :ship_type_id => order_shipping_types(:ups_ground).id
    assert_response :redirect
    assert_redirected_to :action => :confirm_order

    follow_redirect!

    # Verify is was followed.
    assert_template 'confirm_order'
    assert_equal assigns(:title), "Please confirm your order. - Step 3 of 3"
    
    # Purchase
    Order.any_instance.expects(:run_transaction_authorize).once.returns(true)
    
    post 'store/finish_order'
    
    # Ensure download available to customer
    assert_response :success
    assert_select "p", :text => /Card processed successfully/
    assert_select "h2", :text => /Product Downloads/
    url_for_download = url_for(
      :controller => 'customers',
      :action => 'download_for_order',
      :params => {
        :order_number => assigns(:order).order_number,
        :download_id => assigns(:order).downloads.first.id
      },
      :only_path => true
    )
    assert_tag :tag => "a", 
      :attributes => { 
        :href => ERB::Util::html_escape(url_for_download)
      }
    
    # Download file
    get url_for_download
    assert_response :success, "File wasn't downloaded after purchase."
  end
  
  
  def test_cart_and_order_in_sync
    Order.delete_all
    
    # Add two different products to the cart.
    a_cart = nil
    [:holy_grenade, :uranium_portion].each do |sym|
      post '/store/add_to_cart_ajax', :id => items(sym).id
      # Here nothing is rendered directly, but a showPopWin() javascript function is executed.
      a_cart = assigns(:order)
    end
    assert_equal a_cart.items.length, 2
    
    # Checkout & go to shipping page
    post_valid_order()
    assert_response :redirect
    assert_redirected_to :action => :select_shipping_method

    order = assigns(:order)    

    # Delete one item from the cart
    xml_http_request(:post, '/store/remove_from_cart_ajax', :id => items(:holy_grenade).id)
    assert_response :success
    
    # ...It should update the order object.
    order = Order.find(:first)
    assert_equal order.order_line_items.count, 1, "Order items not updated after one was deleted from the cart."    
  end


end
