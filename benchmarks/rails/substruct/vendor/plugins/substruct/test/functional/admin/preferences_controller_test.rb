require File.dirname(__FILE__) + '/../../test_helper'

class Admin::PreferencesControllerTest < ActionController::TestCase
  fixtures :rights, :roles, :users
  fixtures :preferences, :order_shipping_types, :order_shipping_weights


  # Test the index action.
  def test_should_show_index
    login_as :admin

    get :index
    assert_response :success
    assert_template 'index'

    assert_equal assigns(:title), "General Preferences"
    assert_not_nil assigns(:prefs)
  end


  # Test saving preferences.
  def test_should_save_preferences
    login_as :admin

    # Call the index action.
    get :index
    assert_response :success
    assert_template 'index'

    prefs = {
      "store_name" => "My Store",
      "store_handling_fee" => "0.00",
      "store_use_inventory_control" => "1",
      "store_home_country" => { "country_id" => "1" }
    }
    
    post :save_prefs, :prefs => prefs
    
    # If saved we should be redirected to edit form. 
    assert_response :redirect
    assert_redirected_to :action => :index
    
    # Make sure a preference was really changed.
    assert_equal Preference.find_by_name("store_name").value, "My Store"
    
    # Erase a mail preference and try to save another, the system should bother about
    # that.
    Preference.find_by_name("mail_host").destroy
    post :save_prefs, :prefs => prefs
  end

  
  # Test the create action. Here we test if a new valid shipping type will be created.
  def test_should_create_new_shipping_type
    login_as :admin

    shipping_types_count = OrderShippingType.find(:all).length
    
    # Call the shipping action.
    get :shipping
    assert_response :success
    assert_template 'shipping'

    # Initially we should have all shipping types visible.
    assert_select "div#shipping_types" do
      assert_select "div.shipping_type", :count => shipping_types_count
    end

    # Tags should be aded using ajax calls.
    xhr(:post, :add_new_rate_ajax, :shipping_type => {
      :code => "UPWX",
      :name => "UPS Worldwide Express (International Only)",
      :price => 12,
      :is_domestic => 0
    } )

    # It will return a partial.
    assert_select "div.shipping_type", :count => 1

    # Test if it is in the database.
    assert_equal OrderShippingType.find(:all).length, shipping_types_count + 1
  end


  # Test the create action.
  # Here we test if a new valid shipping_type will be created if
  # we pass a blank price.
  def test_should_handle_empty_price
    login_as :admin

    shipping_types_count = OrderShippingType.find(:all).length
    
    # Call the shipping action.
    get :shipping
    assert_response :success
    assert_template 'shipping'

    # Initially we should have all shipping types visible.
    assert_select "div#shipping_types" do
      assert_select "div.shipping_type", :count => shipping_types_count
    end

    # Tags should be aded using ajax calls.
    xhr(:post, :add_new_rate_ajax, :shipping_type => {
      :code => "UPWX",
      :name => "UPS Worldwide Express (International Only)",
      :price => "",
      :is_domestic => 0
    } )

    # The answer will be a javascript popup, we dont have a way to test that.

    # Test if it is NOT in the database.
    assert_equal OrderShippingType.find(:all).length, shipping_types_count+1
  end

  
  # Test the update action. Here we test if a shipping type will be updated with a
  # valid shipping type.
  def test_should_update_shipping_type
    login_as :admin

    shipping_types_count = OrderShippingType.find(:all).length
    a_shipping_type = order_shipping_types(:ups_ground)
    
    # Call the shipping action.
    get :shipping
    assert_response :success
    assert_template 'shipping'

    # Initially we should have all shipping types visible.
    assert_select "div#shipping_types" do
      assert_select "div.shipping_type", :count => shipping_types_count
    end

    # Call the save_shipping action.
    post :save_shipping, :shipping_types => {
      :"#{a_shipping_type.id}" => {
        :name => "UPS Ground",
        :code => "UPG",
        :price => "14.0",
        :is_domestic => "true"
      }
    }
    assert_response :redirect
    assert_redirected_to :action => :shipping


    # Test if it is in the database.
    assert_equal OrderShippingType.find(:all).length, shipping_types_count
    assert_equal OrderShippingType.find(a_shipping_type.id).name, "UPS Ground"
  end


  # Test the update action.
  # Here we test if a shipping type will NOT be updated with an
  # invalid shipping type.
  def test_handle_update_invalid_shipping_type
    login_as :admin

    shipping_types_count = OrderShippingType.find(:all).length
    a_shipping_type = order_shipping_types(:ups_ground)
    
    # Call the shipping action.
    get :shipping
    assert_response :success
    assert_template 'shipping'

    # Initially we should have all shipping types visible.
    assert_select "div#shipping_types" do
      assert_select "div.shipping_type", :count => shipping_types_count
    end

    # Call the save_shipping action.
    post :save_shipping, :shipping_types => {
      :"#{a_shipping_type.id}" => {
        :name => "UPS Ground",
        :code => "UPG",
        :price => "",
        :is_domestic => "true"
      }
    }
    assert_response :redirect
    assert_redirected_to :action => :shipping


    # Test if it is in the database.
    assert_equal OrderShippingType.find(:all).length, shipping_types_count
    assert_equal OrderShippingType.find(a_shipping_type.id).price, 0.0
  end

  
  # Test if we can remove shipping types using ajax calls.
  def test_should_destroy_shipping_type
    login_as :admin

    shipping_types_count = OrderShippingType.find(:all).length
    a_shipping_type = order_shipping_types(:ups_ground)
    
    # Call the shipping action.
    get :shipping
    assert_response :success
    assert_template 'shipping'

    # Initially we should have all shipping types visible.
    assert_select "div#shipping_types" do
      assert_select "div.shipping_type", :count => shipping_types_count
    end

    # OrderShippingTypes should be destroyed using ajax calls.
    xhr(:post, :remove_shipping_type_ajax, :id => a_shipping_type.id)
    
    # At this point, the call doesn't issue a rjs statement, the field is just
    # hidden and the controller method executed, in the end the shipping_type should
    # not be in the database.

    # Test if it was erased from the database.
    assert_equal OrderShippingType.find(:all).length, shipping_types_count - 1
  end


  # Test if a new html chunk will be rendered using ajax, to be possible to
  # add another variation.
  def test_should_add_variation
    login_as :admin

    a_shipping_type = order_shipping_types(:ups_xp_critical)
    
    # Call the shipping action.
    get :shipping
    assert_response :success
    assert_template 'shipping'

    # Initially we should have no variations inside the choosed shipping type.
    assert_select "div#shipping_types" do
      assert_select "div#variations_#{a_shipping_type.id}" do
        assert_select "div.variation", :count => 0
      end
    end
    
    # Variation fields should be aded using ajax calls.
    xhr(:post, :add_shipping_variation_ajax, :id => "#{a_shipping_type.id}")
    
    # We should have one field inserted using a rjs statement.
    assert_select_rjs "variations_#{a_shipping_type.id}" do
      assert_select "div.variation", :count => 1
    end
  end
  

  # Test if we can remove variations using ajax calls.
  def test_should_remove_variation
    login_as :admin

    a_shipping_type = order_shipping_types(:ups_ground)
    a_shipping_weight = order_shipping_weights(:upg_less_3)
    
    # Call the shipping action.
    get :shipping
    assert_response :success
    assert_template 'shipping'

    # Initially we should have three variations inside the choosed shipping type.
    assert_select "div#shipping_types" do
      assert_select "div#variations_#{a_shipping_type.id}" do
        assert_select "div.variation", :count => 3
      end
    end

    # Variations should be erased using ajax calls.
    xhr(:post, :remove_shipping_variation_ajax, :id => a_shipping_weight.id)

    # At this point, the call doesn't issue a rjs statement, the field is just
    # hidden and the controller method executed, in the end the variation should
    # not be in the database.

    assert_equal a_shipping_type.weights.length, 2
  end


end
