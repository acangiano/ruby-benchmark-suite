require File.dirname(__FILE__) + '/../../test_helper'

class Admin::ContentNodesControllerTest < ActionController::TestCase
  fixtures :rights, :roles, :users
  fixtures :content_nodes, :sections


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
    assert_equal assigns(:title), "Content List"
    assert_not_nil assigns(:content_nodes)
  end


  # Test the list action passing keys.
  def test_should_show_list_using_keys
    login_as :admin

    get :list, :key => "Blog"
    assert_response :success
    assert_template 'list'
    assert_equal assigns(:title), "Content List - #{assigns(:viewing_by)}"
    assert_not_nil assigns(:content_nodes)

    get :list, :key => "Page"
    assert_response :success
    assert_template 'list'
    assert_equal assigns(:title), "Content List - #{assigns(:viewing_by)}"
    assert_not_nil assigns(:content_nodes)

    get :list, :key => "Snippet"
    assert_response :success
    assert_template 'list'
    assert_equal assigns(:title), "Content List - #{assigns(:viewing_by)}"
    assert_not_nil assigns(:content_nodes)

    # Here it should sort by name and remember the last key.
    get :list, :sort => "name"
    assert_response :success
    assert_template 'list'
    assert_equal assigns(:title), "Content List - #{assigns(:viewing_by)}"
    assert_not_nil assigns(:content_nodes)

  end
  
  
  # Test the list_sections action.
  def test_should_list_sections
    login_as :admin

    get :list_sections
    assert_response :success
    assert_template 'list_sections'
  end

  
  # Test the list_by_sections action using keys.
  def test_should_list_by_sections
    login_as :admin

    # Call it first without a key, it will use the first by name.
    get :list_by_sections
    assert_response :success
    assert_template 'list'
    assert_equal assigns(:title), "Content List For Section - '#{Section.find_alpha[0].name}'"
    assert_not_nil assigns(:content_nodes)

    
    # Now call it again with a key.
    a_section = sections(:junk_food_news)
    
    get :list_by_sections, :key => a_section.id
    assert_response :success
    assert_template 'list'
    assert_equal assigns(:title), "Content List For Section - '#{a_section.name}'"
    assert_not_nil assigns(:content_nodes)


    # Now call it again without a key, it should remember.
    get :list_by_sections
    assert_response :success
    assert_template 'list'
    assert_equal assigns(:title), "Content List For Section - '#{a_section.name}'"
    assert_not_nil assigns(:content_nodes)


    # Now delete this section making it invalid.
    a_section.destroy
    
    get :list_by_sections, :key => a_section.id
    # If invalid we should be redirected to list. 
    assert_response :redirect
    assert_redirected_to :action => :list
  end
  
  
  # Test the show action.
  def test_should_show_show
    login_as :admin

    a_content_node = content_nodes(:silent_birth)
    
    get :show, :id => a_content_node.id
    assert_response :success
    assert_template 'show'
    assert_not_nil assigns(:content_node)
    assert_equal assigns(:title), "Viewing '#{assigns(:content_node).title}'  "
  end
  
  
  # TODO: Get rid of this method if it will not be used.
  # Test the preview action.
  def test_should_show_preview
    login_as :admin

    get :preview
    assert_response :success
    assert_template 'preview'
  end
  
  
  # Test the create action. Here we test if a new valid content node will be saved.
  def test_should_save_new_content_node
    login_as :admin

    # A file to upload with the content node.
    shrub1 = fixture_file_upload("/files/shrub1.jpg", 'image/jpeg')

    # Call the new form.
    get :new
    assert_response :success
    assert_template 'new'
    
    # Post to it a content node.
    post :create,
    :content_node => {
      :title => "Prophecies for 2008",
      :name => "prophecies",
      :display_on => 1.minute.ago.to_s(:db),
      :content => "According to the Church of Who Knows Where:
    1. The Lord say there would be some scientific breakthrough this year.
    2. There would be some major medical breakthrough this year.
    3. We must pray against destructive hurricane.
    4. To be fore warned is to be fore armed, the flood in this year will be more than last year.
    ",
      :type => "Blog",
      :sections => ["", sections(:prophecies).id.to_s]
    },
    :file => [ {
      :file_data => shrub1,
      :file_data_temp => ""
    }, {
      :file_data => "",
      :file_data_temp => ""
    } ]
    
    # If saved we should be redirected to list. 
    assert_response :redirect
    assert_redirected_to :action => :list
    
    # Verify that the blog post really is there.
    a_blog_post = ContentNode.find_by_name('prophecies')
    assert_not_nil a_blog_post

    # Verify that the file is there.
    an_user_upload = UserUpload.find_by_filename('shrub1.jpg')
    assert_not_nil an_user_upload 

    # We must erase the record and its files by hand, just calling destroy.
    assert an_user_upload.destroy
  end


  # Test the create action. Here we test if a new invalid content node will NOT be
  # saved.
  def test_should_not_save_new_content_node
    login_as :admin

    # Call the new form.
    get :new
    assert_response :success
    assert_template 'new'
    
    # Post to it a content node.
    post :create,
    :content_node => {
      :title => "",
      :name => "",
      :display_on => 1.minute.ago.to_s(:db),
      :content => "",
      :type => "Blog",
      :sections => ["", sections(:prophecies).id.to_s]
    }
    
    # If not saved we will NOT receive a HTTP error status. As we will not be
    # redirected to list action too. The same page will be rendered again with
    # error explanations.
    assert_response :success
    assert_template 'new'

    # Here we assert that the proper fields was marked.
    assert_select "div.fieldWithErrors input#content_node_title"
    assert_select "div.fieldWithErrors input#content_node_name"
    assert_select "div.fieldWithErrors textarea#content_node_content"
  end


  # Change attributes from a content node.
  def test_should_save_existing_question
    login_as :admin
    
    a_content_node = content_nodes(:silent_birth)

    # Call the edit form.
    get :edit, :id => a_content_node.id
    assert_response :success
    assert_template 'edit'

    # Post to it a content node.
    post :update,
    :id => a_content_node.id,
    :content_node => {
      :title => "Silent",
      :name => "silent_birth",
      :display_on => 1.minute.ago.to_s(:db),
      :content => "According to the creator of scientology: Stemming from his belief that birth is a trauma that may induce engrams, he stated that the delivery room should be as silent as possible and that words should be avoided because any words used during birth might be reassociated by adults with their earlier traumatic birth experience. And bla bla bla bla bla ...",
      :type => "Blog",
      :sections => [""]
    },
    :file => [ {
      :file_data => "",
      :file_data_temp => ""
    }, {
      :file_data => "",
      :file_data_temp => ""
    } ]
    
    # If saved we should be redirected to list. 
    assert_response :success
    
    # Verify that the change was made.
    a_content_node.reload
    assert_equal a_content_node.title, "Silent"
  end


  # Change attributes from a content node making it invalid, it should NOT be saved.
  def test_should_not_save_existing_content_node
    login_as :admin
    
    a_content_node = content_nodes(:silent_birth)

    # Call the edit form.
    get :edit, :id => a_content_node.id
    assert_response :success
    assert_template 'edit'

    # Post to it a content node.
    post :update,
    :id => a_content_node.id,
    :content_node => {
      :title => "",
      :name => "",
      :display_on => 1.minute.ago.to_s(:db),
      :content => "According to the creator of scientology: Stemming from his belief that birth is a trauma that may induce engrams, he stated that the delivery room should be as silent as possible and that words should be avoided because any words used during birth might be reassociated by adults with their earlier traumatic birth experience. And bla bla bla bla bla ...",
      :type => "Blog",
      :sections => [""]
    },
    :file => [ {
      :file_data => "",
      :file_data_temp => ""
    }, {
      :file_data => "",
      :file_data_temp => ""
    } ]
    
    # If not saved we will NOT receive a HTTP error status. As we will not be
    # redirected to list action too. The same page will be rendered again with
    # error explanations.
    assert_response :success
    assert_template 'edit'

    # Here we assert that the proper fields was marked.
    assert_select "div.fieldWithErrors input#content_node_title"
    assert_select "div.fieldWithErrors input#content_node_name"
  end


  # Test if we can remove content nodes.
  def test_should_remove_content_node
    login_as :admin

    a_content_node = content_nodes(:silent_birth)

    # Post to it a content_node.
    post :destroy, :id => a_content_node.id

    assert_raise(ActiveRecord::RecordNotFound) {
      ContentNode.find(a_content_node.id)
    }
  end


end
