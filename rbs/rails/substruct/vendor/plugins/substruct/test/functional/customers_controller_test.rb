require File.dirname(__FILE__) + '/../test_helper'

class CustomersControllerTest < ActionController::TestCase
  fixtures :order_users, :orders, :wishlist_items, :items

  # Test the login action.
  def test_should_login
    a_customer = order_users(:santa)

    get :login
    assert_response :success
    assert_equal assigns(:title), "Customer Login"
    assert_template 'login'
    
    post :login, :modal => "", :login => "santa.claus@whoknowswhere.com", :password => "santa"
    # If loged in we should be redirected to orders. 
    assert_response :redirect
    assert_redirected_to :action => :orders
    
    # We need to follow the redirect.
    follow_redirect
    assert_select "p", :text => /Login successful/

    # Assert the customer id is in the session.
    assert_equal session[:customer], a_customer.id
        
    # Test the logout here too.
    post :logout
    assert_response :redirect
    assert_redirected_to '/'

    # Assert the customer id is NOT in the session.
    assert_equal session[:customer], nil

    # Call it again asking for a modal response.
    get :login, :modal => "true"
    assert_response :success
    assert_template 'login'
    
    post :login, :modal => "true", :login => "santa.claus@whoknowswhere.com", :password => "santa"
    assert_response :success
    assert_template 'shared/modal_refresh'
  end


  # Here we test if we can login and return to  previous action.
  def test_should_login_and_return
    # Try to access an action that needs login, the uri should be saved in the session.
    get :account
    
    post :login, :modal => "", :login => "santa.claus@whoknowswhere.com", :password => "santa"
    # If loged in we should be redirected to orders. 
    assert_response :redirect
    assert_redirected_to :action => :account
  end

  # Test the login action with a wrong password.
  def test_should_not_login
    get :login
    assert_response :success
    assert_equal assigns(:title), "Customer Login"
    assert_template 'login'
    
    post :login, :modal => "", :login => "santa.claus@whoknowswhere.com", :password => "wrong_password"
    assert_response :success
    assert_template 'login'
    
    assert_select "p", :text => /Login unsuccessful/

    assert_equal session[:customer], nil
  end


  # Test the create action. Here we test if a new valid customer will be saved.
  def test_should_save_new_customer
    # Call the new form.
    get :new
    assert_response :success
    assert_equal assigns(:title), "New Account"
    assert_template 'new'
    
    # Post to it a customer.
    post :new,
    :customer => {
      :email_address => "customer@nowhere.com",
      :password => "password"
    }
    
    # If saved we should be redirected. 
    assert_response :redirect
    assert_redirected_to :action => :wishlist

    # We need to follow the redirect.
    follow_redirect
    assert_select "p", :text => /Your account has been created./
    
    # Verify that the customer really is there.
    a_customer = OrderUser.find_by_email_address('customer@nowhere.com')
    assert_not_nil a_customer

    # Assert the customer id is in the session.
    assert_equal session[:customer], a_customer.id
  end


  # Test the create action. Here we test if a new valid customer will be saved and we will return.
  def test_should_save_new_customer_and_return
    # Try to access an action that needs login, the uri should be saved in the session.
    get :account
    
    # Login.
    login_as_customer :mustard
    
    # Post to it a customer.
    post :new,
    :customer => {
      :email_address => "customer@nowhere.com",
      :password => "password"
    }
    
    # If saved we should be redirected to the saved uri. 
    assert_response :redirect
    assert_redirected_to :action => :account
  end


  # Test the new action. Here we test if a new invalid cutomer will NOT be saved.
  def test_should_not_save_new_customer
    # Call the new form.
    get :new
    assert_response :success
    assert_equal assigns(:title), "New Account"
    assert_template 'new'
    
    # Post to it a new invalid customer.
    post :new,
    :customer => {
      :email_address => "customer",
      :password => "password"
    }
    
    # If not saved, the same page will be rendered again with error explanations.
    assert_response :success
    assert_template 'new'

    # Here we assert that a flash message appeared and the proper fields was marked.
    assert_select "p", :text => /There was a problem creating your account./
    assert_select "div.fieldWithErrors input#customer_email_address"

  
    # Post to it an already existing customer.
    post :new,
    :customer => {
      :email_address => "colonel.mustard@whoknowswhere.com",
      :password => "password"
    }
    
    # If not saved, the same page will be rendered again with error explanations.
    assert_response :success
    assert_template 'new'

    # Here we assert that a flash message appeared and the proper fields was marked.
    assert_select "p", :text => /There was a problem creating your account./
    assert_select "div.fieldWithErrors input#customer_email_address"
  end


  # Change attributes from a customer.
  def test_should_save_existing_customer
    login_as_customer :mustard
    
    a_customer = order_users(:mustard)
    
    # Call the edit form.
    get :account
    assert_response :success
    assert_equal assigns(:title), "Your Account Details"
    assert_template 'account'

    new_email_address = "#{a_customer.email_address}.changed"
    
    # Post to it the current customer changed.
    post :account,
    :customer => {
      :email_address => new_email_address,
      :password => "#{a_customer.password}"
    }
    
    assert_response :success
    assert_template 'account'

    # Here we assert that a flash message appeared.
    assert_select "p", :text => /Account details saved./
    
    # Verify that the change was made.
    a_customer.reload
    assert_equal a_customer.email_address, new_email_address
  end


  # Test that the attributes from a customer will NOT be changed.
  def test_should_not_save_existing_customer
    login_as_customer :mustard
    
    a_customer = order_users(:mustard)
    
    # Call the edit form.
    get :account
    assert_response :success
    assert_equal assigns(:title), "Your Account Details"
    assert_template 'account'

    old_email_address = a_customer.email_address
    
    # Post to it the current customer changed.
    post :account,
    :customer => {
      :email_address => "invalid",
      :password => "#{a_customer.password}"
    }
    
    assert_response :success
    assert_template 'account'

    # Here we assert that a flash message appeared and the proper fields was marked.
    assert_select "p", :text => /There was a problem saving your account./
    assert_select "div.fieldWithErrors input#customer_email_address"
    
    # Verify that the change was NOT made.
    a_customer.reload
    assert_equal a_customer.email_address, old_email_address
  end


  # Reset the password from a customer.
  def test_should_reset_customer_password
    # Setup the mailer.
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    initial_mbox_length = ActionMailer::Base.deliveries.length

    a_customer = order_users(:mustard)
    
    # Call the reset_password form.
    get :reset_password
    assert_response :success
    assert_equal assigns(:title), "Reset Password"
    assert_template 'reset_password'

    old_password = a_customer.password
    
    # Post to it the current customer changed.
    post :reset_password,
    :modal => "",
    :login => a_customer.email_address
    
    # If done should redirect to login. 
    assert_response :redirect
    assert_redirected_to :action => :login

    # We need to follow the redirect.
    follow_redirect
    assert_select "p", :text => /Your password has been reset and emailed to you./
    
    # Verify that the change was made.
    a_customer.reload
    assert_not_equal a_customer.password, old_password

    # We should have received a mail about that.
    assert_equal ActionMailer::Base.deliveries.length, initial_mbox_length + 1

  
    # Call again the reset_password form in a modal state.
    get :reset_password, :modal => "true"
    assert_response :success
    assert_equal assigns(:title), "Reset Password"
    assert_template 'reset_password'
  end
  

  # Don't reset the password from a customer.
  def test_should_not_reset_customer_password
    # Setup the mailer.
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    initial_mbox_length = ActionMailer::Base.deliveries.length

    # Call the reset_password form.
    get :reset_password
    assert_response :success
    assert_equal assigns(:title), "Reset Password"
    assert_template 'reset_password'
    
    # Post to it an invalid customer.
    post :reset_password,
    :modal => "",
    :login => "invalid"
    
    assert_response :success
    assert_template 'reset_password'

    # Here we assert that a flash message appeared.
    assert_select "p", :text => /That account wasn/

    # We should NOT receive a mail about that.
    assert_equal ActionMailer::Base.deliveries.length, initial_mbox_length
  end


  # Test the orders action.
  def test_should_show_orders
    login_as_customer :santa

    a_customer = order_users(:santa)

    get :orders
    assert_response :success
    assert_equal assigns(:title), "Your Orders"
    assert_template 'orders'
    assert_not_nil assigns(:orders)
    
    # Assert all orders are being shown.
    assert_select "h1", :text => /Your Orders/
    order_numbers_array = a_customer.orders.collect {|p| p.order_number}
    order_numbers_array.each do |item|
      assert_select "td", :text => item
    end
  end


  # Test the wishlist action.
  def test_should_show_wishlist
    login_as_customer :santa

    a_customer = order_users(:santa)

    get :wishlist
    assert_response :success
    assert_equal assigns(:title), "Your Wishlist"
    assert_template 'wishlist'
    assert_not_nil assigns(:items)
    
    # Assert all items of the wishlist are being shown.
    assert_select "h1", :text => /Your Wishlist/
    wishlist_items_array = a_customer.items.collect {|p| p.name}
    wishlist_items_array.each do |item|
      assert_select "a", :text => item
    end
  end
  
  
  # Test if we can add a new item to the wishlist.
  def test_should_add_to_wishlist
    login_as_customer :mustard

    a_customer = order_users(:mustard)
    a_product = items(:towel)

    get :wishlist
    assert_response :success
    assert_equal assigns(:title), "Your Wishlist"
    assert_template 'wishlist'
    assert_not_nil assigns(:items)
    
    # Initially we should have no items.
    assert_select "h3", :text => /No items are in your wishlist at this time./

    # Add an item.
    post :add_to_wishlist, :id => a_product.id
    
    # If done should redirect to wishlist. 
    assert_response :redirect
    assert_redirected_to :action => :wishlist
    
    # Assert we were redirected.
    follow_redirect
    assert_select "h1", :text => /Your Wishlist/

    # Assert all items of the wishlist are being shown.
    assert_equal a_customer.items.length, 1
    wishlist_items_array = a_customer.items.collect {|p| p.name}
    wishlist_items_array.each do |item|
      assert_select "a", :text => item
    end
  end


  # Test that an invalid item will not be added to the wishlist.
  def test_should_not_add_to_wishlist
    login_as_customer :mustard

    # Crete a new product, hold its id and destroy it, this guarantees that we have an invalid id.
    inexistent_product = Product.new(
      :code => "SHRUBBERY",
      :name => "Shrubbery",
      :description => "A shrubbery. One that looks nice, and is not too expensive. Perfect for a knight who say Ni.",
      :price => 90.50,
      :date_available => "2007-12-01 00:00",
      :quantity => 38,
      :size_width => 24,
      :size_height => 24,
      :size_depth => 12,
      :weight => 21.52
    )
    assert inexistent_product.save
    inexistent_product_id = inexistent_product.id
    assert inexistent_product.destroy
    
    a_customer = order_users(:mustard)

    get :wishlist
    assert_response :success
    assert_equal assigns(:title), "Your Wishlist"
    assert_template 'wishlist'
    assert_not_nil assigns(:items)
    
    # Initially we should have no items.
    assert_select "h3", :text => /No items are in your wishlist at this time./

    # Add an inexistent item.
    post :add_to_wishlist, :id => inexistent_product_id
    
    # Even on error should redirect to wishlist. 
    assert_response :redirect
    assert_redirected_to :action => :wishlist
    
    # Assert we were redirected.
    follow_redirect
    assert_select "p", :text => /find the item that you wanted to add to your wishlist. Please try again./
    assert_select "h1", :text => /Your Wishlist/

    # Assert nothing has been added.
    assert_equal a_customer.items.length, 0
    assert_select "h3", :text => /No items are in your wishlist at this time./

  
    # Now without an item id.
    post :add_to_wishlist
    
    # Even on error should redirect to wishlist. 
    assert_response :redirect
    assert_redirected_to :action => :wishlist
    
    # Assert we were redirected.
    follow_redirect
    assert_select "p", :text => /specify an item to add to your wishlist.../
    assert_select "h1", :text => /Your Wishlist/

    # Assert nothing has been added.
    assert_equal a_customer.items.length, 0
    assert_select "h3", :text => /No items are in your wishlist at this time./
  end


  # Test if we can remove wishlist items using ajax calls.
  def test_should_remove_wishlist_item
    login_as_customer :santa

    a_customer = order_users(:santa)
    a_product = items(:uranium_portion)

    get :wishlist
    assert_response :success
    assert_equal assigns(:title), "Your Wishlist"
    assert_template 'wishlist'
    assert_not_nil assigns(:items)
    
    # Initially we should have two items.
    assert_select "div.padLeft" do
      assert_select "div.product", :count => 2
    end

    # Items should be erased using ajax calls.
    xhr(:post, :remove_wishlist_item, :id => a_product.id)

    # At this point, the call doesn't issue a rjs statement, the field is just
    # hidden and the controller method executed, in the end the item should
    # not be in the database.

    assert_equal a_customer.items.length, 1
  end


  # Test if the email address can be checked.
  def test_should_check_email_address
    # TODO: This should be trigered in checkout when the field is being filled.

    a_customer = order_users(:santa)

    # The email address should be checked using ajax calls.
    xhr(:post, :check_email_address, :email_address => a_customer.email_address)

    # Here an insertion rjs statement is not generated, a javascript function
    # is just spited out to be executed.
    # puts @response.body

    # Post again with an invalid address.
    xhr(:post, :check_email_address, :email_address => "invalid")
  end

  # Login as santa, download digital good (towel pix)
  def test_can_download_digital_good
    post :login, :modal => "", :login => "santa.claus@whoknowswhere.com", :password => "santa"
    assert_response :redirect
    assert_redirected_to :action => :orders

    order = orders(:santa_next_christmas_order)    
    # Download file
    get :download_for_order, :order_number => order.order_number, :download_id => order.downloads.first.id
    assert_response :success, "File wasn't downloaded after purchase."
    
    # Try to download with wrong order number
    get :download_for_order, :order_number => 12345789, :download_id => order.downloads.first.id
    assert_response :missing, "File was downloaded when it shouldn't have been."
    
    # Try to download with wrong download id
    get :download_for_order, :order_number => order.order_number, :download_id => (order.downloads.first.id+10)
    assert_response :missing, "File was downloaded when it shouldn't have been."
  end

end
