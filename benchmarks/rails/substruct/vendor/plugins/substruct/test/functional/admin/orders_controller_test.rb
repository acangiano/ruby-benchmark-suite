$: << '.'
require File.dirname(__FILE__) + '/../../test_helper'

class Admin::OrdersControllerTest < ActionController::TestCase
  fixtures :all
  
  # Test the index action.
  def test_show_index
    login_as :admin

    get :index
    assert_response :success
    assert_template 'list'
  end


  # Test the list action.
  def test_show_list
    login_as :admin

    # Call it first without a key, it will use the first value of list_options array.
    get :list
    assert_response :success
    assert_template 'list'
    assert_equal assigns(:title), "Order List"
    assert_not_nil assigns(:orders)
    assert_select "td", :count => 1, :text => "ORDERED - PAID - TO SHIP"
    
    # Now call it again with a key.
    get :list, :key => "On Hold"
    assert_response :success
    assert_template 'list'
    assert_equal assigns(:title), "Order List"
    assert assigns(:orders)
    assert_select "td", :count => 2, :text => /ON HOLD/

    # Now call it again without a key, it should remember the last key.
    get :list
    assert_response :success
    assert_template 'list'
    assert_equal assigns(:title), "Order List"
    assert_not_nil assigns(:orders)
    assert_select "td", :count => 2, :text => /ON HOLD/

    # Now call it again with a key.
    get :list, :key => "Completed"
    assert_response :success
    assert_template 'list'
    assert_equal assigns(:title), "Order List"
    assert assigns(:orders)
    assert_select "td", :count => 2, :text => /ORDERED - PAID/
    assert_select "td", :count => 1, :text => /SENT TO FULFILLMENT/

    # Now call it again with a key.
    get :list, :key => "All"
    assert_response :success
    assert_template 'list'
    assert_equal assigns(:title), "Order List"
    assert assigns(:orders)
    assert_select "a", :count => 9, :text => /Santa Claus/
  end


  # We should get a list of orders searching by name or number.
  def test_search
    login_as :admin

    a_term = "santa"

    # Search using a term.
    get :search, :term => a_term
    assert_response :success
    assert_equal assigns(:title), "Search Results"
    assert_select "h2", :text => "You Searched For '#{a_term}'"
    assert_equal assigns(:search_count), 9
    assert assigns(:orders)
    assert_template 'list'

    # Now without a term, it should remember the last.
    get :search
    assert_response :success
    assert_select "h2", :text => "You Searched For '#{a_term}'"
  end


  # We should get a list of orders searching by e-mail.
  def test_search_by_email
    login_as :admin

    a_term = "whoknowswhere"

    # Search using a term.
    get :search_by_email, :term => a_term
    assert_response :success
    assert_equal assigns(:title), "Search Results"
    assert_select "h2", :text => "You Searched For '#{a_term}'"
    assert_select "a", :count => 9, :text => /Santa Claus/
    assert assigns(:orders)
    assert_template 'list'

    # Now without a term, it should remember the last.
    get :search_by_email
    assert_response :success
    assert_select "h2", :text => "You Searched For '#{a_term}'"
  end


  # We should get a list of orders searching by notes.
  def test_search_by_notes
    login_as :admin

    a_term = "Order failed"

    # Search using a term.
    get :search_by_notes, :term => a_term
    assert_response :success
    assert_equal assigns(:title), "Search Results"
    assert_select "h2", :text => "You Searched For '#{a_term}'"
    assert_select "a", :count => 1, :text => /Santa Claus/
    assert assigns(:orders)
    assert_template 'list'

    # Now without a term, it should remember the last.
    get :search_by_notes
    assert_response :success
    assert_select "h2", :text => "You Searched For '#{a_term}'"
  end


  # Test if the sales totals by year will be generated. 
  def test_get_sales_totals
    login_as :admin

    get :totals
    assert_response :success
    assert_template 'totals'
    assert_equal assigns(:title), "Sales Totals"
    assert_not_nil assigns(:years)

    an_order = orders(:santa_next_christmas_order)
    a_month = an_order.created_on.month

    # Test last year.
    last_year = assigns(:years)[1.year.ago.year.to_s]
    last_year[a_month][0] = 1
    last_year[a_month][1] = an_order.product_cost
    last_year[a_month][2] = an_order.tax
    last_year[a_month][3] = an_order.shipping_cost

    an_order = orders(:an_order_ordered_paid_shipped)
    a_month = an_order.created_on.month
    another_order = orders(:an_order_sent_to_fulfillment)
    another_month = another_order.created_on.month
    assert_equal a_month, another_month

    # Test current year.
    current_year = assigns(:years)[Time.now.year.to_s]
    current_year[a_month][0] = 1
    current_year[a_month][1] = an_order.product_cost + another_order.product_cost
    current_year[a_month][2] = an_order.tax + another_order.tax
    current_year[a_month][3] = an_order.shipping_cost + another_order.shipping_cost
  end


  # We should get a list of orders by country.
  def test_get_orders_by_country
    login_as :admin

    get :by_country
    assert_response :success
    assert_equal assigns(:title), "Orders By Country"
    assert assigns(:countries)
    assert_template 'by_country'

    assert_select "a", :text => "#{countries(:US).name} - #{countries(:US).number_of_orders}"
  end


  # We should get a list of orders for a specific country.
  def test_get_orders_for_country
    login_as :admin

    a_country = countries(:US)

    get :for_country, :id => a_country.id
    assert_response :success
    assert_equal assigns(:title), "Orders for #{a_country.name}"
    assert_equal assigns(:order_count), a_country.number_of_orders
    assert assigns(:orders)
    assert_template 'list'

    # Now without an id, we should be redirected to by_country action.
    get :for_country
    assert_response :redirect
    assert_redirected_to :action => :by_country
  end

  # Mocks viewing an order that hasn't gone past the checkout stage.
  def test_show_cart_order
    login_as :admin
    order = Order.create
    get :show, :id => order.id
    assert_response :success
  end

  # Change attributes from order, order_user, order_address, etc.
  # TODO: Maybe is not good idea to change the order_user's e-mail address from here.
  # TODO: The @products array is not being used.
  # May exist others orders that uses the same record.
  def test_allow_edit_order
    login_as :admin

    an_order = orders(:santa_next_christmas_order)
    an_order_shipping_type = order_shipping_types(:ups_ground)
    an_order_status_code = order_status_codes(:ordered_paid_shipped)

    # Call the show form.
    get :show, :id => an_order.id
    assert_response :success
    assert_template 'edit' if an_order.order_status_code.is_editable?

    old_email_address = an_order.order_user.email_address
    
    post :update, 
    :id => an_order.id,
    :order => {
      :new_notes => "Hello friend",
      :order_shipping_type_id => an_order_shipping_type.id,
      :shipping_cost => an_order_shipping_type.price,
      :order_status_code_id => an_order_status_code.id
    },
    :order_user => {
      :email_address => "#{an_order.order_user.email_address}.changed"
    },
    :billing_address => {
      :city => "South Pole",
      :zip => an_order.billing_address.zip,
      :country_id => an_order.billing_address.country.id,
      :first_name => an_order.billing_address.first_name,
      :telephone => an_order.billing_address.telephone,
      :last_name => an_order.billing_address.last_name,
      :address => an_order.billing_address.address,
      :state => an_order.billing_address.state
    },
    # The shipping address is used only if said to use a different address.
    :use_separate_shipping_address => "true",
    :shipping_address => {
      :city => an_order.shipping_address.city,
      :zip => "123456",
      :country_id => an_order.shipping_address.country.id,
      :first_name => an_order.shipping_address.first_name,
      :telephone => an_order.shipping_address.telephone,
      :last_name => an_order.shipping_address.last_name,
      :address => an_order.shipping_address.address,
      :state => an_order.shipping_address.state
    },
    :order_account => {
      :cc_number => an_order.order_account.cc_number,
      :expiration_year => an_order.order_account.expiration_year,
      :expiration_month => "12"
    }
    
    # If saved we should be redirected to edit form. 
    assert_response :redirect
    assert_redirected_to :action => :show, :id => an_order.id
    
    # Verify that the order and everything else was changed.
    an_order.reload
    assert_equal an_order.order_shipping_type, an_order_shipping_type
    assert_equal an_order.order_status_code, an_order_status_code
    assert_equal an_order.order_user.email_address, "#{old_email_address}.changed"
    assert_equal an_order.billing_address.city, "South Pole"
    assert_equal an_order.shipping_address.zip, "123456"
    assert_equal an_order.order_account.expiration_month, 12
    assert an_order.notes.include?("Hello friend")

    # As the order was finished, make it show again, it should use the show template now.
    # Call the show form.
    get :show, :id => an_order.id
    assert_response :success
    assert_template 'show'
  end


  # Should NOT change the order attributes.
  def test_not_allow_edit_wrong_order
    login_as :admin

    an_order = orders(:santa_next_christmas_order)

    # Call the show form.
    get :show, :id => an_order.id
    assert_response :success
    assert_template 'edit' if an_order.order_status_code.is_editable?

    # Stub the Order.order_user method (called by update_order_from_post from inside a module) to raise an exception.
    Order.any_instance.expects(:order_user).raises('An error!')

    post :update, 
    :id => an_order.id,
    :order => {
      :new_notes => "",
      :order_shipping_type_id => "",
      :shipping_cost => "",
      :order_status_code_id => ""
    }

    # If not saved we will NOT receive a HTTP error status. As we will not be
    # redirected to show action too. The same page will be rendered again with
    # error explanations.
    assert_response :success
    assert_template 'edit'
    assert_select "div#flash", :text => /There were problems modifying the order./
  end

  
  # TODO: This is an empty method.
  def test_void_order
  end


  # Test if an order can be marked as returned.
  def test_return_order
    login_as :admin

    an_order = orders(:santa_next_christmas_order)

    # Call the resend_receipt action.
    post :return_order, :id => an_order.id

    # If succeded we should be redirected to show form. 
    assert_response :redirect
    assert_redirected_to :action => :show, :id => an_order.id

    # The status code should have changed.
    an_order.reload
    assert_equal an_order.order_status_code, order_status_codes(:returned)
  end


  # Test if a receipt message will be sent again.
  def test_resend_receipt
    login_as :admin

    # Setup the mailer.
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    initial_mbox_length = ActionMailer::Base.deliveries.length

    an_order = orders(:santa_next_christmas_order)

    # Call the resend_receipt action.
    post :resend_receipt, :id => an_order.id

    # If succeded we should be redirected to show form. 
    assert_response :redirect
    assert_redirected_to :action => :show, :id => an_order.id
    
    # We should have received a mail about that.
    assert_equal ActionMailer::Base.deliveries.length, initial_mbox_length + 1
  end


  # Test if we can remove an order.
  def test_remove_order
    login_as :admin

    an_order = orders(:santa_next_christmas_order)
    an_order_line_item = an_order.order_line_items.find(:first)

    post :destroy, :id => an_order.id
    assert_response :redirect
    assert_redirected_to :action => :list

    # We should not find the order anymore.
    assert_raise(ActiveRecord::RecordNotFound) {
      Order.find(an_order.id)
    }
    assert_raise(ActiveRecord::RecordNotFound) {
      OrderLineItem.find(an_order_line_item.id)
    }    
  end


  # Test if we can download an order list.
  def test_download_orders_csv
    login_as :admin
    
    ids_array = Order.find(:all).collect {|p| p.id}


    # Test the CSV file download.

    # Call the download action.
    get :download, :format => "csv", :ids => ids_array
    assert_response :success

    # Why not Content-Type?
    assert_equal @response.headers['type'], "text/csv"
    
    # Create a regular expression.
    re = %r{\d{2}_\d{2}_\d{4}_\d{2}-\d{2}[.]csv}
    # See if it matches Content-Disposition, and create a MatchData object.
    md = re.match(@response.headers['Content-Disposition'])
    # Assert it matched something.
    assert_not_nil md

    # Assert something was generated and remove it.
    file = File.join(RAILS_ROOT, "public/system/order_files", md[0])
    was_created = File.exist?(file)
    assert was_created
    if was_created
      FileUtils.remove_file(file)
    end


    # Test the XML file download.

    # Call the download action.
    get :download, :format => "xml", :ids => ids_array
    assert_response :success

    # Why not Content-Type?
    assert_equal @response.headers['type'], "text/xml"
    
    # Create a regular expression.
    re = %r{\d{2}_\d{2}_\d{4}_\d{2}-\d{2}[.]xml}
    # See if it matches Content-Disposition, and create a MatchData object.
    md = re.match(@response.headers['Content-Disposition'])
    # Assert it matched something.
    assert_not_nil md

    # Assert something was generated and remove it.
    file = File.join(RAILS_ROOT, "public/system/order_files", md[0])
    was_created = File.exist?(file)
    assert was_created
    if was_created
      FileUtils.remove_file(file)
    end
  end

end
