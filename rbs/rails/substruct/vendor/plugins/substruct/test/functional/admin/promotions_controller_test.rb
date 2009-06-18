require File.dirname(__FILE__) + '/../../test_helper'

class Admin::PromotionsControllerTest < ActionController::TestCase
  fixtures :rights, :roles, :users
  fixtures :promotions, :items


  # Test the index action.
  def test_should_show_index
    login_as :admin

    get :index
    assert_response :success
    assert_template 'list'
  end


  # Test the list action.
  def test_should_show_list
    login_as :admin

    get :list
    assert_response :success
    assert_template 'list'
    assert_equal assigns(:title), "Promotion List"
    assert_not_nil assigns(:promotions)
  end


  # Test the create action. Here we test if a new valid promotion will be saved.
  def test_should_save_new_promotion
    login_as :admin

    # Call the new form.
    get :new
    assert_response :success
    assert_template 'new'
    
    # Post to it a promotion.
    post :create,
    :promotion => {
      :code => "NUCLEAR_REBATE",
      :description => "U$ 50.00 discount, just today.",
      :discount_type => 0,
      :discount_amount => 50,
      :minimum_cart_value => "",
      :start => 1.day.ago.to_s(:db),
      :end => 1.day.from_now.to_s(:db)
    }
    
    # If saved we should be redirected to list. 
    assert_response :redirect
    assert_redirected_to :action => :list
    
    # Verify that the promotion really is there.
    a_promotion = Promotion.find_by_code('NUCLEAR_REBATE')
    assert_not_nil a_promotion
  end


  # Test the create action. Here we test if a new invalid promotion will NOT be
  # saved.
  def test_should_not_save_new_promotion
    login_as :admin

    # Call the new form.
    get :new
    assert_response :success
    assert_template 'new'
    
    # Post to it a promotion.
    post :create,
    :promotion => {
      :code => "",
      :description => "",
      :discount_type => 0,
      :discount_amount => 50,
      :minimum_cart_value => "",
      :start => 1.day.ago.to_s(:db),
      :end => 1.day.from_now.to_s(:db)
    }
    
    # If not saved we will NOT receive a HTTP error status. As we will not be
    # redirected to list action too. The same page will be rendered again with
    # error explanations.
    assert_response :success
    assert_template 'new'

    # Here we assert that the proper fields was marked.
    assert_select "div.fieldWithErrors input#promotion_code"
    assert_select "div.fieldWithErrors input#promotion_description"
  end


  # Change attributes from promotion.
  def test_should_save_existing_promotion
    login_as :admin
    
    a_promotion = promotions(:fixed_rebate)

    # Call the edit form.
    get :edit, :id => a_promotion.id
    assert_response :success
    assert_template 'edit'

    # Post to it a promotion.
    post :update,
    :id => a_promotion.id,
    :promotion => {
      :code => "FIXED_REBATE",
      :description => "Buying anything, get a U$ 5.00 discount, extended period.",
      :discount_type => 0,
      :discount_amount => 5,
      :minimum_cart_value => "",
      :start => 1.minute.ago.to_s(:db),
      :end => 1.day.from_now.to_s(:db)
    }
    
    # If saved we should be redirected to list. 
    assert_response :redirect
    assert_redirected_to :action => :list
    
    # Verify that the change was made.
    a_promotion.reload
    assert_equal a_promotion.description, "Buying anything, get a U$ 5.00 discount, extended period."
  end


  # Change attributes from promotion making it invalid, it should NOT be saved.
  def test_should_not_save_existing_promotion
    login_as :admin
    
    a_promotion = promotions(:fixed_rebate)

    # Call the edit form.
    get :edit, :id => a_promotion.id
    assert_response :success
    assert_template 'edit'

    # Post to it a promotion.
    post :update,
    :id => a_promotion.id,
    :promotion => {
      :code => "",
      :description => "",
      :discount_type => 0,
      :discount_amount => 5,
      :minimum_cart_value => "",
      :start => 1.minute.ago.to_s(:db),
      :end => 1.day.from_now.to_s(:db)
    }
    
    # If not saved we will NOT receive a HTTP error status. As we will not be
    # redirected to list action too. The same page will be rendered again with
    # error explanations.
    assert_response :success
    assert_template 'edit'

    # Here we assert that the proper fields was marked.
    assert_select "div.fieldWithErrors input#promotion_code"
    assert_select "div.fieldWithErrors input#promotion_description"
  end


  # Test if we can remove promotions.
  def test_should_remove_promotion
    login_as :admin

    a_promotion = promotions(:fixed_rebate)

    # Post to it a promotion.
    post :destroy, :id => a_promotion.id

    assert_raise(ActiveRecord::RecordNotFound) {
      Promotion.find(a_promotion.id)
    }
  end


  # Test if we can show orders for a promotion.
  def test_should_show_orders_for_promotion
    login_as :admin

    a_promotion = promotions(:fixed_rebate)

    # Call the show_orders action.
    get :show_orders, :id => a_promotion.id
    assert_response :success
    assert_template 'show_orders'

    assert_equal assigns(:title), "Orders for #{a_promotion.code}"
    assert_not_nil assigns(:orders)
  end


end
