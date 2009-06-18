require File.dirname(__FILE__) + '/../../test_helper'

class Admin::FilesControllerTest < ActionController::TestCase
  fixtures :rights, :roles, :users
  fixtures :user_uploads


  # Test the index action.
  def test_should_show_index
    login_as :admin

    get :index
    assert_response :success
    assert_template 'index'
    assert_equal assigns(:title), "List of user uploaded files"
    assert_not_nil assigns(:files)
  end


  # Test the list action passing keys.
  def test_should_show_index_using_keys
    login_as :admin

    get :index, :key => "Image"
    assert_response :success
    assert_template 'index'
    assert_equal assigns(:title), "List of user uploaded files - #{assigns(:viewing_by).pluralize}"
    assert_not_nil assigns(:files)

    get :index, :key => "Asset"
    assert_response :success
    assert_template 'index'
    assert_equal assigns(:title), "List of user uploaded files - #{assigns(:viewing_by).pluralize}"
    assert_not_nil assigns(:files)

    get :index, :sort => "name"
    assert_response :success
    assert_template 'index'
    assert_equal assigns(:title), "List of user uploaded files"
    assert_not_nil assigns(:files)
  end
  
  
  # Test if we can remove files.
  def test_should_remove_file
    login_as :admin

    an_user_upload = user_uploads(:lightsaber_blue_upload)

    # Post to it a content_node.
    post :destroy, :id => an_user_upload.id

    assert_raise(ActiveRecord::RecordNotFound) {
      UserUpload.find(an_user_upload.id)
    }
  end


  def test_should_upload_file
    login_as :admin
    
    lightsabers_image = fixture_file_upload("/files/lightsabers.jpg", 'image/jpeg')

    # Go to the index.
    get :index
    assert_response :success
    assert_template 'index'

    # Post an image.
    post :upload,
    :file => [ {
        :file_data_temp => "",
        :file_data => lightsabers_image
      }, {
        :file_data_temp => "",
        :file_data => ""
    } ]

    # If saved we should be redirected to index. 
    assert_response :redirect
    assert_redirected_to :action => :index
    
    # Verify that the file is there.
    an_user_upload = UserUpload.find_by_filename('lightsabers.jpg')
    assert_not_nil an_user_upload 

    # We must erase the record and its files by hand, just calling destroy.
    assert an_user_upload.destroy
  end

end
