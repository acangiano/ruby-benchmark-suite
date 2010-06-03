$: << '.'
require File.dirname(__FILE__) + '/../test_helper'

class AccountsControllerTest < ActionController::TestCase
  fixtures :rights, :roles, :users


  # Test the login action.
  def test_should_login
    an_user = users(:c_norris)

    get :login
    assert_response :success
    assert_template 'login'
    
    post :login, :user_login => "c_norris", :user_password => "admin"
    # If loged in we should be redirected to welcome. 
    assert_response :redirect
    assert_redirected_to :action => :welcome
    
    # We need to follow the redirect.
    follow_redirect
    assert_select "p", :text => /You are now logged into the system/

    # Assert the user id is in the session.
    assert_equal session[:user], an_user.id
    
    
    # Test the logout here too.
    post :logout
    assert_response :success
    assert_template 'logout'
  end


  # Test the login action with a wrong password.
  def test_should_not_login
    get :login
    assert_response :success
    assert_template 'login'
    
    post :login, :user_login => "c_norris", :user_password => "wrong_password"
    assert_response :success
    assert_template 'login'
    
    assert_select "div#message", :text => /Login unsuccessful/

    assert_equal session[:user], nil
  end


  # Test the signup action.
  def test_should_signup
    # TODO: This action isn't used by the system.
    # The code is wrong, User.count.zero? will never be true, so, it will always redirect to login action.
    # If the user is created with success this leads then to a DoubleRenderError.
  end


end
