$: << '.'
require File.dirname(__FILE__) + '/../../test_helper'

class Admin::SectionsControllerTest < ActionController::TestCase
  fixtures :rights, :roles, :users
  fixtures :sections


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
    
    # No parameters.
    get :list
    assert_response :success
    assert_template 'list'
    assert_equal assigns(:title), "Manage Sections"
    assert_not_nil assigns(:sections)
  end
  
  
  # Test the list action.
  def test_should_show_list_of_children
    login_as :admin
    
    # Valid name with children.
    # TODO: Very weird, pass a name in a parameter called id.
    get :list, :id => sections(:usefull_news).name 
    assert_response :success
    assert_template 'list'
    assert_equal assigns(:title), "Manage Sections"
    assert_not_nil assigns(:sections)
  end
  
  
  # Test the list action.
  def test_should_show_list_root_if_invalid
    login_as :admin

    # Invalid name.
    get :list, :id => "INVALID"
    assert_response :success
    assert_template 'list'
    assert_equal assigns(:title), "Manage Sections"
    assert_not_nil assigns(:sections)
    assert_select "div#flash"
  end


  # Test if we can update section ranks using ajax.
  def test_should_update_section_rank
    login_as :admin

    a_section = sections(:junk_food_news)
    
    # Child sections are already ordered by rank.
    position1 = a_section.children[0]
    position2 = a_section.children[1]

    # Call the list method, passing a section name
    get :list, :id => a_section.name
    assert_response :success
    assert_template 'list'

    # Initially we should have two visible sections.
    assert_select "ul#section_list" do
      assert_select "li", :count => 2
    end

    # Sections should be ordered using ajax calls.
    xhr(:post, :update_rank, :section_list => [position2.id, position1.id])
 
    # At this point, the call doesn't issue a rjs statement, the fields are just
    # sorted and the controller method executed, in the end the sections should be
    # ranked in another way.

    # Reload it an see if the order changed.
    a_section.reload
    
    # Child sections are already ordered by rank.
    new_position1 = a_section.children[0]
    new_position2 = a_section.children[1]

    # Compare the positions.
    assert_equal new_position1, position2
    assert_equal new_position2, position1
  end


  # Test the create action. Here we test if a new valid section will be created.
  def test_should_create_new_section
    login_as :admin

    parent_sections_count = Section.find_ordered_parents.length
    
    # Call the list action.
    get :list
    assert_response :success
    assert_template 'list'

    # Initially we should have all parent sections visible.
    assert_select "ul#section_list" do
      assert_select "li", :count => parent_sections_count
    end

    # Sections should be aded using ajax calls.
    xhr(:post, :create, :section => { :name => "New Section" })

    # It will return a partial.
    assert_select "li", :count => 1

    # Test if it is in the database.
    assert_equal Section.find_ordered_parents.length, parent_sections_count + 1
  end


  # Test the create action. Here we test if a new valid section will be created and
  # its parent section assigned.
  def test_should_create_new_section_with_parent_assigned
    login_as :admin
    
    parent_section = sections(:junk_food_news)
    children_sections_count = parent_section.children.count
    
    # Call the list action.
    get :list, :id => parent_section.name 
    assert_response :success
    assert_template 'list'

    # Initially we should have all parent sections visible.
    assert_select "ul#section_list" do
      assert_select "li", :count => children_sections_count
    end

    # Sections should be aded using ajax calls.
    xhr(:post, :create, :id => parent_section.id, :section => { :name => "Annoying Paparazzi" })

    # It will return a partial.
    assert_select "li", :count => 1

    # Reload the parent.
    parent_section.reload
    
    # Test if it is in the database.
    assert_equal parent_section.children.count, children_sections_count + 1
  end


  # Test the create action. Here we test if a new valid section will be created.
  def test_should_not_create_invalid_section
    login_as :admin

    parent_sections_count = Section.find_ordered_parents.length
    
    # Call the list action.
    get :list
    assert_response :success
    assert_template 'list'

    # Initially we should have all parent sections visible.
    assert_select "ul#section_list" do
      assert_select "li", :count => parent_sections_count
    end

    # Variation fields should be aded using ajax calls.
    xhr(:post, :create, :section => { :name => "Usefull News" })

    # The answer will be a javascript popup, we dont have a way to test that.

    # Test if it is NOT in the database.
    assert_equal Section.find_ordered_parents.length, parent_sections_count
  end

  
  # Test the update action. Here we test if a section will be updated with a valid
  # section.
  def test_should_update_section
    login_as :admin

    parent_sections_count = Section.find_ordered_parents.length
    a_section = sections(:celebrity_pregnancies)
    
    # Call the list action.
    get :list
    assert_response :success
    assert_template 'list'

    # Initially we should have all parent sections visible.
    assert_select "ul#section_list" do
      assert_select "li", :count => parent_sections_count
    end

    # Sections should be updated using ajax calls.
    xhr(:post, :update, :id => a_section.id, :name => "Celebrity News")

    # We should have a piece of html modified using a rjs statement.
    assert_select_rjs "section_#{a_section.id}" do
      assert_select "li", :count => 1
    end

    # Test if it is in the database.
    assert_equal Section.find_ordered_parents.length, parent_sections_count
    assert_equal Section.find(a_section.id).name, "Celebrity News"
  end


  # Test the update action. Here we test if a section will NOT be updated with an
  # invalid section.
  def test_should_not_update_invalid_section
    login_as :admin

    parent_sections_count = Section.find_ordered_parents.length
    a_section = sections(:celebrity_pregnancies)
    
    # Call the list action.
    get :list
    assert_response :success
    assert_template 'list'

    # Initially we should have all parent sections visible.
    assert_select "ul#section_list" do
      assert_select "li", :count => parent_sections_count
    end

    # Sections should be updated using ajax calls.
    xhr(:post, :update, :id => a_section.id, :name => "")
    #puts "#{@response.body}"
    
    # At this point, the call doesn't issue a rjs statement.

    # Test if it is in the database.
    assert_equal Section.find_ordered_parents.length, parent_sections_count
    assert_equal Section.find(a_section.id).name, "Celebrity Pregnancies"
  end

  
  # Test if we can remove sections using ajax calls.
  def test_should_destroy_section
    login_as :admin

    parent_sections_count = Section.find_ordered_parents.length
    a_section = sections(:prophecies)
    
    # Call the list action.
    get :list
    assert_response :success
    assert_template 'list'

    # Initially we should have all parent sections visible.
    assert_select "ul#section_list" do
      assert_select "li", :count => parent_sections_count
    end

    # Sections should be destroyed using ajax calls.
    xhr(:post, :destroy, :id => a_section.id)
    
    # At this point, the call doesn't issue a rjs statement, the field is just
    # hidden and the controller method executed, in the end the section should
    # not be in the database.

    # Test if it was erased from the database.
    assert_equal Section.find_ordered_parents.length, parent_sections_count - 1
  end


end
