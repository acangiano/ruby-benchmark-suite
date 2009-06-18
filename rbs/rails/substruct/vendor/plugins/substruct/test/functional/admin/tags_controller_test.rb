require File.dirname(__FILE__) + '/../../test_helper'

class Admin::TagsControllerTest < ActionController::TestCase
  fixtures :rights, :roles, :users
  fixtures :tags


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
    assert_equal assigns(:title), "Manage Tags"
    assert_not_nil assigns(:tags)
  end
  
  
  # Test the list action.
  def test_should_show_list_of_children
    login_as :admin
    
    # Valid name with children.
    # TODO: Very weird, pass a name in a parameter called id.
    get :list, :id => tags(:weapons).name 
    assert_response :success
    assert_template 'list'
    assert_equal assigns(:title), "Manage Tags"
    assert_not_nil assigns(:tags)
  end
  
  
  # Test the list action.
  def test_should_show_list_root_if_invalid
    login_as :admin

    # Invalid name.
    get :list, :id => "INVALID"
    assert_response :success
    assert_template 'list'
    assert_equal assigns(:title), "Manage Tags"
    assert_not_nil assigns(:tags)
    assert_select "div#flash"
  end


  # Test if we can update tag ranks using ajax.
  def test_should_update_tag_rank
    login_as :admin

    a_tag = tags(:weapons)
    
    # Child tags are already ordered by rank.
    position1 = a_tag.children[0]
    position2 = a_tag.children[1]
    position3 = a_tag.children[2]

    # Call the list method, passing a tag name
    get :list, :id => a_tag.name
    assert_response :success
    assert_template 'list'

    # Initially we should have three visible tags.
    assert_select "ul#tag_list" do
      assert_select "li", :count => 3
    end

    # Tags should be ordered using ajax calls.
    xhr(:post, :update_tag_rank, :tag_list => [position2.id, position1.id, position3.id])
 
    # At this point, the call doesn't issue a rjs statement, the fields are just
    # sorted and the controller method executed, in the end the tags should be
    # ranked in another way.

    # Reload it an see if the order changed.
    a_tag.reload
    
    # Child tags are already ordered by rank.
    new_position1 = a_tag.children[0]
    new_position2 = a_tag.children[1]
    new_position3 = a_tag.children[2]

    # Compare the positions.
    assert_equal new_position1, position2
    assert_equal new_position2, position1
    assert_equal new_position3, position3
  end


  # Test the create action. Here we test if a new valid tag will be created.
  def test_should_create_new_tag
    login_as :admin

    parent_tags_count = Tag.find_ordered_parents.length
    
    # Call the list action.
    get :list
    assert_response :success
    assert_template 'list'

    # Initially we should have all parent tags visible.
    assert_select "ul#tag_list" do
      assert_select "li", :count => parent_tags_count
    end

    # Tags should be aded using ajax calls.
    xhr(:post, :create, :tag => { :name => "Toy Guns" })

    # It will return a partial.
    assert_select "li", :count => 1

    # Test if it is in the database.
    assert_equal Tag.find_ordered_parents.length, parent_tags_count + 1
  end


  # Test the create action. Here we test if a new valid tag will be created and
  # its parent tag assigned.
  def test_should_create_new_tag_with_parent_assigned
    login_as :admin
    
    parent_tag = tags(:weapons)
    children_tags_count = parent_tag.children.count
    
    # Call the list action.
    get :list, :id => parent_tag.name 
    assert_response :success
    assert_template 'list'

    # Initially we should have all parent tags visible.
    assert_select "ul#tag_list" do
      assert_select "li", :count => children_tags_count
    end

    # Tags should be aded using ajax calls.
    xhr(:post, :create, :id => parent_tag.id, :tag => { :name => "Toy Guns" })

    # It will return a partial.
    assert_select "li", :count => 1

    # Reload the parent.
    parent_tag.reload
    
    # Test if it is in the database.
    assert_equal parent_tag.children.count, children_tags_count + 1
  end


  # Test the create action. Here we test if a new valid tag will be created.
  def test_should_not_create_invalid_tag
    login_as :admin

    parent_tags_count = Tag.find_ordered_parents.length
    
    # Call the list action.
    get :list
    assert_response :success
    assert_template 'list'

    # Initially we should have all parent tags visible.
    assert_select "ul#tag_list" do
      assert_select "li", :count => parent_tags_count
    end

    # Variation fields should be aded using ajax calls.
    xhr(:post, :create, :tag => { :name => "Weapons" })

    # The answer will be a javascript popup, we dont have a way to test that.

    # Test if it is NOT in the database.
    assert_equal Tag.find_ordered_parents.length, parent_tags_count
  end

  
  # Test the update action. Here we test if a tag will be updated with a valid
  # tag.
  def test_should_update_tag
    login_as :admin

    parent_tags_count = Tag.find_ordered_parents.length
    a_tag = tags(:books)
    
    # Call the list action.
    get :list
    assert_response :success
    assert_template 'list'

    # Initially we should have all parent tags visible.
    assert_select "ul#tag_list" do
      assert_select "li", :count => parent_tags_count
    end

    # Tags should be updated using ajax calls.
    xhr(:post, :update, :id => a_tag.id, :name => "Books and Magazines")

    # We should have a piece of html modified using a rjs statement.
    assert_select_rjs "tag_#{a_tag.id}" do
      assert_select "li", :count => 1
    end

    # Test if it is in the database.
    assert_equal Tag.find_ordered_parents.length, parent_tags_count
    assert_equal Tag.find(a_tag.id).name, "Books and Magazines"
  end


  # Test the update action. Here we test if a tag will NOT be updated with an
  # invalid tag.
  def test_should_not_update_invalid_tag
    login_as :admin

    parent_tags_count = Tag.find_ordered_parents.length
    a_tag = tags(:books)
    
    # Call the list action.
    get :list
    assert_response :success
    assert_template 'list'

    # Initially we should have all parent tags visible.
    assert_select "ul#tag_list" do
      assert_select "li", :count => parent_tags_count
    end

    # Tags should be updated using ajax calls.
    xhr(:post, :update, :id => a_tag.id, :name => "")
    #puts "#{@response.body}"
    
    # At this point, the call doesn't issue a rjs statement.

    # Test if it is in the database.
    assert_equal Tag.find_ordered_parents.length, parent_tags_count
    assert_equal Tag.find(a_tag.id).name, "Books"
  end

  
  # Test if we can remove tags using ajax calls.
  def test_should_destroy_tag
    login_as :admin

    parent_tags_count = Tag.find_ordered_parents.length
    a_tag = tags(:books)
    
    # Call the list action.
    get :list
    assert_response :success
    assert_template 'list'

    # Initially we should have all parent tags visible.
    assert_select "ul#tag_list" do
      assert_select "li", :count => parent_tags_count
    end

    # Tags should be destroyed using ajax calls.
    xhr(:post, :destroy, :id => a_tag.id)
    
    # At this point, the call doesn't issue a rjs statement, the field is just
    # hidden and the controller method executed, in the end the tag should
    # not be in the database.

    # Test if it was erased from the database.
    assert_equal Tag.find_ordered_parents.length, parent_tags_count - 1
  end


end
