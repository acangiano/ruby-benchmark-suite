require File.dirname(__FILE__) + '/../../test_helper'

class Admin::RolesControllerTest < ActionController::TestCase
  fixtures :rights, :roles, :users


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
    assert_equal assigns(:title), "Role List"
    assert_not_nil assigns(:roles)
  end


  # Test the create action. Here we test if a new valid role will be saved.
  def test_should_save_new_role
    login_as :admin

    # Call the new form.
    get :new
    assert_response :success
    assert_template 'edit'
    
    # Post to it a role.
    post :new,
    :role => {
      :name => "Common User",
      :description => "An user that have few rights.",
      :right_ids => ["", rights(:content_crud).id.to_s]
    }
    
    # If saved we should be redirected to list. 
    assert_response :redirect
    assert_redirected_to :action => :list
    
    # Verify that the role really is there.
    a_role = Role.find_by_name('Common User')
    assert_not_nil a_role
  end


  # Test the create action. Here we test if a new invalid role will NOT be
  # saved.
  def test_should_not_save_new_role
    login_as :admin

    # Call the new form.
    get :new
    assert_response :success
    assert_template 'edit'
    
    # Post to it a role.
    post :new,
    :role => {
      :name => "",
      :description => ""
    }
    
    # If not saved we will NOT receive a HTTP error status. As we will not be
    # redirected to list action too. The same page will be rendered again with
    # error explanations.
    assert_response :success
    assert_template 'edit'

    # Here we assert that the proper fields was marked.
    assert_select "div.fieldWithErrors input#role_name"
  end


  # Change attributes from role.
  def test_should_save_existing_role
    login_as :admin
    
    a_role = roles(:owner_role)

    # Call the edit form.
    get :edit, :id => a_role.id
    assert_response :success
    assert_template 'edit'

    # Post to it a role.
    post :edit,
    :id => a_role.id,
    :role => {
      :name => "Owner",
      :description => "Can access everything in Substruct, but just say to YOU do it."
    }
    
    # If saved we should be redirected to list. 
    assert_response :redirect
    assert_redirected_to :action => :list
    
    # Verify that the change was made.
    a_role.reload
    assert_equal a_role.description, "Can access everything in Substruct, but just say to YOU do it."
  end


  # Change attributes from role making it invalid, it should NOT be saved.
  def test_should_not_save_existing_role
    login_as :admin
    
    a_role = roles(:owner_role)

    # Call the edit form.
    get :edit, :id => a_role.id
    assert_response :success
    assert_template 'edit'

    # Post to it a role.
    post :edit,
    :id => a_role.id,
    :role => {
      :name => "",
      :description => ""
    }
    
    # If not saved we will NOT receive a HTTP error status. As we will not be
    # redirected to list action too. The same page will be rendered again with
    # error explanations.
    assert_response :success
    assert_template 'edit'

    # Here we assert that the proper fields was marked.
    assert_select "div.fieldWithErrors input#role_name"
  end


  # Test if we can remove roles.
  def test_should_remove_role
    login_as :admin

    a_role = roles(:owner_role)

    # Post to it a role.
    post :destroy, :id => a_role.id

    assert_raise(ActiveRecord::RecordNotFound) {
      Role.find(a_role.id)
    }
  end


end
