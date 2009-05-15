require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase
  fixtures :users


  # Test if a valid user can be created with success.
  def test_should_create_user
    an_user = User.new(
      :login => "root",
      :password => "password",
      :password_confirmation => "password"
    )
  
    assert an_user.save
  end


  # Test if a user can be found with success.
  def test_should_find_user
    an_user_id = users(:admin).id
    assert_nothing_raised {
      User.find(an_user_id)
    }
  end


  # Test if an user can be updated with success.
  def test_should_update_user
    an_user = users(:admin)
    
    # Here we are renaming an user.
#    an_user.update_attributes(
#      :login => 'administrator',
#      :password => "",
#      :password_confirmation => ""
#    )
    an_user.login = 'administrator'
    an_user.password = ""
    an_user.password_confirmation = ""
    
    assert an_user.save
    
    # Obs. When renaming an user don't use update_attributes and set both password
    # and password_confirmtion to an empty string.
  end


  # Test if an user password can be updated with success.
  def test_should_update_user
    an_user = users(:admin)
    
    an_user.password = "another_password"
    an_user.password_confirmation = "another_password"
    
    assert an_user.save
  end
  
  
  # Test if a user can be destroyed with success.
  def test_should_destroy_user
    an_user = users(:admin)
    an_user.destroy
    assert_raise(ActiveRecord::RecordNotFound) {
      User.find(an_user.id)
    }
  end


  # Test if an invalid user really will NOT be created.
  def test_should_not_create_invalid_user
    # Using the interface an user can be created with an empty password but not
    # with a nil one.
    an_user = User.new(
      :login => "",
      :password => "",
      :password_confirmation => ""
    )

    # A user must have a login, and it must be long enough.
    assert !an_user.valid?
    assert an_user.errors.invalid?(:login)
    assert_equal ["is too short (minimum is 3 characters)", "can't be blank"], an_user.errors.on(:login)

    # A user must have a not so long login.
    an_user.login = "my_very_very_very_very_very_very_long_login"
    assert !an_user.valid?
    assert an_user.errors.invalid?(:login)
    assert_equal "is too long (maximum is 40 characters)", an_user.errors.on(:login)

    # A user must have an unique login.
    an_user.login = "admin"
    assert !an_user.valid?
    assert an_user.errors.invalid?(:login)
    assert_equal "has already been taken", an_user.errors.on(:login)

    # A user must have a password, and it must be longer than 5 characters.
    an_user.login = "login_ok"
    an_user.password = ""
    an_user.password_confirmation = ""
    assert !an_user.valid?
    assert an_user.errors.invalid?(:password)
    assert_equal " must be between 5 and 40 characters.", an_user.errors.on(:password)

    # A user must have a password, and it must be shorter than 40 characters.
    an_user.login = "login_ok"
    an_user.password = "my_very_very_very_very_very_long_password"
    an_user.password_confirmation = "my_very_very_very_very_very_long_password"
    assert !an_user.valid?
    assert an_user.errors.invalid?(:password)
    assert_equal " must be between 5 and 40 characters.", an_user.errors.on(:password)

    # A user must have a password confirmation that matches the password.
    an_user.login = "login_ok"
    an_user.password = "a_password"
    an_user.password_confirmation = ""
    assert !an_user.valid?
    assert an_user.errors.invalid?(:password)
    assert_equal " and confirmation don't match.", an_user.errors.on(:password)
    an_user.password_confirmation = "another_password"
    assert !an_user.valid?
    assert an_user.errors.invalid?(:password)
    assert_equal " and confirmation don't match.", an_user.errors.on(:password)

    assert !an_user.save
  end


  # Test if a user can be authenticated.
  def test_should_authenticate_user
    an_user = users(:admin)
    
    assert_equal an_user, User.authenticate("admin", "admin")
    assert User.authenticate?("admin", "admin")
  end
  
  
  # Test if a user will be authenticated.
  def test_should_authenticate_user
    assert_equal User.find_by_login("admin"), User.authenticate("admin", "admin")
    assert User.authenticate?("admin", "admin")
  end
  
  
  # Test if a user with a wrong password will NOT be authenticated.
  def test_should_not_authenticate_user
    assert_equal nil, User.authenticate("admin", "wrongpassword")
    assert !User.authenticate?("admin", "wrongpassword")
  end
  
  
end