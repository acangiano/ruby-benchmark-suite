$: << '.'
require File.dirname(__FILE__) + '/../test_helper'

class RoleTest < ActiveSupport::TestCase
  fixtures :roles, :rights


  # Test if a valid role can be created with success.
  def test_should_create_role
    a_role = Role.new
    
    a_role.name = "Common User"
    a_role.description = "An user that have few rights."
    a_role.right_ids = ["", rights(:content_crud).id.to_s]
  
    assert a_role.save
  end
  
  
  # Test if a role can be found with success.
  def test_should_find_role
    a_role_id = roles(:administrator_role).id
    assert_nothing_raised {
      Role.find(a_role_id)
    }
  end


  # Test if a role can be updated with success.
  def test_should_update_role
    a_role = roles(:administrator_role)
    assert a_role.update_attributes(:description => 'Access everything.')
  end


  # Test if a role can be destroyed with success.
  def test_should_destroy_role
    a_role = roles(:owner_role)
    a_role.destroy
    assert_raise(ActiveRecord::RecordNotFound) {
      Role.find(a_role.id)
    }
  end


  # Test if an invalid role really will NOT be created.
  def test_should_not_create_invalid_role
    a_role = Role.new
    assert !a_role.valid?
    assert a_role.errors.invalid?(:name)
    assert_equal "can't be blank", a_role.errors.on(:name)

    assert !a_role.save
  end


  # Test if rights can be associated and disassociated by ids.
  def test_should_associate_rights_by_ids
    owner_role = roles(:owner_role)
    assert_equal owner_role.rights.count, 0
    # Load some rights and see if it really have just one related role.
    orders_right = rights(:orders_all)
    products_right = rights(:products_all)
    assert_equal orders_right.roles.count, 1
    assert_equal products_right.roles.count, 1

    # Associate one with the others and all must know about that.
    # TODO: a_role.right_ids should receive ids but its not doing that.
    # owner_role.right_ids = [ orders_right.id, products_right.id ]
    owner_role.right_ids = orders_right.id.to_s, products_right.id.to_s
    assert_equal owner_role.rights.count, 2
    assert_equal orders_right.roles.count, 2
    assert_equal products_right.roles.count, 2

    # Clear all and verify.
    owner_role.rights.clear
    assert_equal orders_right.roles.count, 1
    assert_equal products_right.roles.count, 1
  end


end