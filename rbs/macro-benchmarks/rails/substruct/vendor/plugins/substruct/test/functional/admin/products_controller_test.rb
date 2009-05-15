require File.dirname(__FILE__) + '/../../test_helper'

class Admin::ProductsControllerTest < ActionController::TestCase
  fixtures :all

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
    assert_equal assigns(:title), "All Product List"
    assert_not_nil assigns(:products)
    
    # Theres a before_filter that sets tags in all actions.
    assert_not_nil assigns(:tags)
  end


  # We should get a list of tags and how many products it have associated.
  def test_should_list_tags
    login_as :admin

    get :list_tags
    assert_response :success
    assert_template 'list_tags'
  end


  # We should get a list of products that belongs to a tag.
  def test_should_list_by_tags_passing_a_key
    login_as :admin

    # Call it first without a key, it will use the first by name.
    get :list_by_tags
    assert_response :success
    assert_equal assigns(:title), "Product List For Tag - '#{Tag.find_alpha[0].name}'"
    assert assigns(:products)
    assert_template 'list'

    # Now call it again with a key.
    a_tag = tags(:weapons)
    get :list_by_tags, :key => a_tag.id
    assert_response :success
    assert_equal assigns(:title), "Product List For Tag - '#{a_tag.name}'"
    assert assigns(:products)
    assert_template 'list'

    # Now call it again without a key, it should remember.
    get :list_by_tags
    assert_response :success
    assert_equal assigns(:title), "Product List For Tag - '#{a_tag.name}'"
    assert assigns(:products)
    assert_template 'list'

    # Now delete this tag making it invalid.
    a_tag.destroy
    get :list_by_tags, :key => a_tag.id
    # If invalid we should be redirected to list. 
    assert_response :redirect
    assert_redirected_to :action => :list

  end


  # We should get a list of products using a search term.
  def test_should_search
    login_as :admin

    a_term = "lightsaber"
    get :search, :term => a_term
    assert_response :success
    assert_equal assigns(:title), "Search Results For '#{a_term}'"
    # It should only list products, not variations.
    assert_equal assigns(:search_count), 1
    assert assigns(:products)
    assert_template 'list'

    # Now without a term, it should remember the last.
    get :search
    assert_response :success
    assert_equal assigns(:title), "Search Results For '#{a_term}'"
  end


  # It should fill the items variable and return a javascript snippet to be ready
  # to feed the suggestion list on auto-completion.
  def test_suggest_js
    login_as :admin

    get :suggestion_js
    assert_response :success
    assert assigns(:items)

    get :suggestion_js, :show_all_items => true
    assert_response :success
    assert assigns(:items)

    # TODO: Verify if this shouldn't be a helper.

    # Here an insertion rjs statement is not generated, a javascript defined
    # array is just spited out.
    # puts "#{@response.body}"
  end


  # Test the save action. The save action can receive a variety of information
  # together from the form. Here we test if a new valid product will be saved.
  def test_should_save_new_product
    login_as :admin

    # Call the new form.
    get :new
    assert_response :success
    assert_template 'new'
    
    # Post to it a product and an empty image.
    post :save,
    :product => {
      :code => "SHRUBBERY",
      :name => "Shrubbery",
      :description => "A shrubbery. One that looks nice, and is not too expensive. Perfect for a knight who say Ni.",
      :price => 90.50,
      :date_available => "2007-12-01 00:00",
      :quantity => 38,
      :size_width => 24,
      :size_height => 24,
      :size_depth => 12,
      :weight => 21.52,
      :related_product_suggestion_names => ["", "", "", "", ""],
      :tag_ids => [""]
    },
    :image => [ {
      :image_data_temp => "",
      :image_data => ""
    }, {
      :image_data_temp => "",
      :image_data => ""
    } ],
    :download => []
    
    # If saved we should be redirected to edit form. 
    assert_response :redirect
    assert_redirected_to :action => :edit
    
    # Verify that the product really is there and it doesn't have images.
    a_product = Product.find_by_code('SHRUBBERY')
    assert_not_nil a_product 
    assert_equal a_product.images.count, 0
  end


  # Test the save action. The save action can receive a variety of information
  # together from the form. Here we test if a new valid product will be saved, but
  # it should warn that the image could not be saved.
  def test_should_save_new_product_but_not_the_image
    login_as :admin

    # In turn of an image, try to upload a text file in its place.
    text_asset = fixture_file_upload("/files/text_asset.txt", 'text/plain')

    # Call the new form.
    get :new
    assert_response :success
    assert_template 'new'
    
    # Post to it a product and an empty image.
    post :save,
    :product => {
      :code => "SHRUBBERY",
      :name => "Shrubbery",
      :description => "A shrubbery. One that looks nice, and is not too expensive. Perfect for a knight who say Ni.",
      :price => 90.50,
      :date_available => "2007-12-01 00:00",
      :quantity => 38,
      :size_width => 24,
      :size_height => 24,
      :size_depth => 12,
      :weight => 21.52,
      :related_product_suggestion_names => ["", "", "", "", ""],
      :tag_ids => [""]
    },
    :image => [ {
      :image_data_temp => "",
      :image_data => text_asset
      }, {
      :image_data_temp => "",
      :image_data => ""
    } ],
    :download => []
    
    # If saved we should be redirected to edit form. 
    assert_response :redirect
    assert_redirected_to :action => :edit
    
    # Verify that the product really is there and it doesn't have images.
    a_product = Product.find_by_code('SHRUBBERY')
    assert_not_nil a_product 
    assert_equal a_product.images.count, 0

    # The signal that the image has problems is a flash message, we need to follow
    # the redirect to see it.
    follow_redirect
    assert_select "div#flash"
  end


  # Test the save action. The save action can receive a variety of information
  # together from the form. Here we test if a new invalid product will NOT be
  # saved.
  def test_should_not_save_new_product
    login_as :admin

    # Call the new form.
    get :new
    assert_response :success
    assert_template 'new'
    
    # Post to it a product and an empty image.
    post :save,
    :product => {
      :code => "",
      :name => "",
      :description => "A shrubbery. One that looks nice, and is not too expensive. Perfect for a knight who say Ni.",
      :price => 90.50,
      :date_available => "2007-12-01 00:00",
      :quantity => 38,
      :size_width => 24,
      :size_height => 24,
      :size_depth => 12,
      :weight => 21.52,
      :related_product_suggestion_names => ["", "", "", "", ""],
      :tag_ids => [""]
    },
    :image => [ {
      :image_data_temp => "",
      :image_data => ""
    }, {
      :image_data_temp => "",
      :image_data => ""
    } ]
    
    # If not saved we will NOT receive a HTTP error status. As we will not be
    # redirected to edit action too. The same page will be rendered again with
    # error explanations.
    assert_response :success
    assert_template 'new'

    # Here we assert that an error explanation was given and that the proper
    # fields was marked.
    assert_select "div#errorExplanation"
    assert_select "div.fieldWithErrors input#product_name"
    assert_select "div.fieldWithErrors input#product_code"
  end


  # Test if a new valid product will be saved, but create everything that can be
  # created together, images, related products, tags, variations, etc.
  def test_should_save_new_product_associated_with_everything
    login_as :admin

    a_towel = items(:towel)
    a_coat = items(:chinchilla_coat)
    a_weird_tag = tags(:weird)
    
    # Call the new form.
    get :new
    assert_response :success
    assert_template 'new'
    
    # Variation ids are set using time so we need sleep 1 second to get two
    # different ids.
    var_id_1 = Time.now.to_i
    sleep 1
    var_id_2 = Time.now.to_i
    
    shrub1 = fixture_file_upload("/files/shrub1.jpg", 'image/jpeg')
    shrub2 = fixture_file_upload("/files/shrub2.jpg", 'image/jpeg')

    post :save,
    :product => {
      :code => "SHRUBBERY",
      :name => "Shrubbery",
      :description => "A shrubbery. One that looks nice, and is not too expensive. Perfect for a knight who say Ni.",
      :price => 90.50,
      :date_available => "2007-12-01 00:00",
      :quantity => 38,
      :size_width => 24,
      :size_height => 24,
      :size_depth => 12,
      :weight => 21.52,
      :related_product_suggestion_names => [a_towel.suggestion_name, a_coat.suggestion_name, "", "", ""],
      :tag_ids => ["", "#{a_weird_tag.id}"]
    },
    :variation => [ {
        :id => var_id_1,
        :code => "SMALL_SHRUBBERY",
        :name => "Small",
        :price => 65.99,
        :quantity => 200
      }, {
        :id => var_id_2,
        :code => "LARGE_SHRUBBERY",
        :name => "Large",
        :price => 98.99,
        :quantity => 310
    } ],
    :image => [ {
        :image_data_temp => "",
        :image_data => shrub1
      }, {
        :image_data_temp => "",
        :image_data => shrub2
      }, {
        :image_data_temp => "",
        :image_data => ""
    } ],
    :download => []
    
    # If saved we should be redirected to edit form. 
    assert_response :redirect
    assert_redirected_to :action => :edit
    
    # Verify that the product and everything else are there.
    a_product = Product.find_by_code('SHRUBBERY')
    assert_not_nil a_product 
    assert_equal a_product.related_products, [a_coat, a_towel]
    assert_equal a_product.tags.count, 1, "Wrong tag count."
    assert_equal a_product.variations.count, 2, "Wrong variation count."
    assert_equal a_product.images.count, 2, "Wrong image count."
    
    # Clean up system dir.
    a_product.images[0].destroy
    a_product.images[1].destroy
  end


  # Test if a new valid product will be saved, but create everything that can be
  # created together, images, related products, tags, variations, etc, making
  # these associated objects invalid.
  def test_should_save_new_product_and_discard_invalid_associations
    login_as :admin

    # Call the new form.
    get :new
    assert_response :success
    assert_template 'new'
    
    # Variation ids are set using time so we need sleep 1 second to get two
    # different ids.
    var_id_1 = Time.now.to_i
    sleep 1
    var_id_2 = Time.now.to_i
    
    post :save,
    :product => {
      :code => "SHRUBBERY",
      :name => "Shrubbery",
      :description => "A shrubbery. One that looks nice, and is not too expensive. Perfect for a knight who say Ni.",
      :price => 90.50,
      :date_available => "2007-12-01 00:00",
      :quantity => 38,
      :size_width => 24,
      :size_height => 24,
      :size_depth => 12,
      :weight => 21.52,
      # An invalid related product.
      :related_product_suggestion_names => ["Bla: Bla Bla", "", "", "", ""],
      # Invalid tags cannot be selected using the interface.
      :tag_ids => [""]

    },
    :variation => [ {
        :id => var_id_1,
        :code => "",
        :name => "",
        :price => 65.99,
        :quantity => 200
      }, {
        :id => var_id_2,
        :code => "",
        :name => "",
        :price => 98.99,
        :quantity => 310
    } ],
    :image => [ {
        :image_data_temp => "",
        :image_data => ""
      }, {
        :image_data_temp => "",
        :image_data => ""
    } ],
    :download => []
    
    # If saved we should be redirected to edit form. 
    assert_response :redirect
    assert_redirected_to :action => :edit
    
    # Verify that the product and everything else are there.
    a_product = Product.find_by_code('SHRUBBERY')
    assert_not_nil a_product
    # Invalid related products should be ignored.
    assert_equal a_product.related_products, []
    assert_equal a_product.tags.count, 0
    # Invalid variations should be discarted and ignored.
    assert_equal a_product.variations.count, 0
    assert_equal a_product.images.count, 0
  end


  # Change attributes from product, change attributes from variations,
  # disassociate from tags and related products.
  def test_should_save_existing_product_associated_with_everything
    login_as :admin

    a_product = items(:lightsaber)
    a_red_variation = items(:red_lightsaber)
    a_blue_variation = items(:blue_lightsaber)
    a_green_variation = items(:green_lightsaber)

    # Call the edit form.
    get :edit, :id => a_product.id
    assert_response :success
    assert_template 'edit'

    post :save, 
    :id => a_product.id,
    :product => {
      :code => "LIGHTSABER",
      :name => "Lightsaber",
      :description => "For you that ever wanted to be a Jedi but didn't had a lightsaber.",
      :price => 90.50,
      :date_available => "2000-01-01 00:00",
      :quantity => 22,
      :size_width => 2,
      :size_height => 50,
      :size_depth => 2,
      :weight => 1.45,
      :related_product_suggestion_names => ["", "", "", "", ""],
      :tag_ids => []
    },
    # Variations should be sent again in the params hash to be possible to change
    # its attributes, but if one is missed it is NOT erased nor disassociated,
    # they must have ids.
    :variation => [ {
        :id => a_red_variation.id,
        :code => "RED_LIGHTSABER",
        :name => "Red",
        :price => 89.50,
        :quantity => 5
    }, {
        :id => a_blue_variation.id,
        :code => "BLUE_LIGHTSABER",
        :name => "Blue",
        :price => 91.50,
        :quantity => 5
    }, {
        :id => a_green_variation.id,
        :code => "YELLOW_LIGHTSABER",
        :name => "Yellow",
        :price => 93.50,
        :quantity => 5
    } ]
    
    # If saved we should be redirected to edit form. 
    assert_response :redirect
    assert_redirected_to :action => :edit
    
    # Verify that the product and everything else are there.
    a_product.reload
    assert_equal a_product.related_products.count, 0
    assert_equal a_product.tags.count, 0
    # Sending an empty array of variations doesn't erase them.
    assert_equal a_product.variations.count, 3
    assert_equal a_product.images.count, 3
    a_green_variation.reload
    assert_equal a_green_variation.code, "YELLOW_LIGHTSABER"
  end


  # Change attributes from product making it invalid, it should NOT be saved.
  def test_should_not_save_existing_product
    login_as :admin

    a_product = items(:lightsaber)
    a_red_variation = items(:red_lightsaber)
    a_blue_variation = items(:blue_lightsaber)
    a_green_variation = items(:green_lightsaber)

    # Call the edit form.
    get :edit, :id => a_product.id
    assert_response :success
    assert_template 'edit'

    post :save, 
    :id => a_product.id,
    :product => {
      :code => "",
      :name => "",
      :description => "For you that ever wanted to be a Jedi but didn't had a lightsaber.",
      :price => 90.50,
      :date_available => "2000-01-01 00:00",
      :quantity => 22,
      :size_width => 2,
      :size_height => 50,
      :size_depth => 2,
      :weight => 1.45,
      :related_product_suggestion_names => ["Bla: Bla Bla", "", "", "", ""],
      :tag_ids => [""]
    },
    # Variations should be sent again in the params hash to be possible to change
    # its attributes, but if one is missed it is NOT erased nor disassociated,
    # they must have ids.
    :variation => [ {
        :id => a_red_variation.id,
        :code => "RED_LIGHTSABER",
        :name => "Red",
        :price => 89.50,
        :quantity => 5
    }, {
        :id => a_blue_variation.id,
        :code => "BLUE_LIGHTSABER",
        :name => "Blue",
        :price => 91.50,
        :quantity => 5
    }, {
        :id => a_green_variation.id,
        :code => "YELLOW_LIGHTSABER",
        :name => "Yellow",
        :price => 93.50,
        :quantity => 5
    } ],
    :image => [ {
        :image_data_temp => "",
        :image_data => ""
      }, {
        :image_data_temp => "",
        :image_data => ""
    } ]
    
    # If not saved we will NOT receive a HTTP error status. As we will not be
    # redirected to edit action too. The same page will be rendered again with
    # error explanations.
    assert_response :success
    assert_template 'edit'

    # Here we assert that an error explanation was given and that the proper
    # fields was marked.
    assert_select "div#errorExplanation"
    assert_select "div.fieldWithErrors input#product_name"
    assert_select "div.fieldWithErrors input#product_code"
    
    # Verify that the product and everything else are there.
    a_product.reload
    assert_equal a_product.related_products.count, 0
    assert_equal a_product.tags.count, 0
    # Sending an empty array of variations doesn't erase them.
    assert_equal a_product.variations.count, 3
    assert_equal a_product.images.count, 3
    # Variations are NOT saved if the product give an error.
    a_green_variation.reload
    assert_equal a_green_variation.code, "GREEN_LIGHTSABER"
  end


  # Test if we can remove variations using ajax calls.
  def test_should_remove_variation
    login_as :admin

    a_product = items(:lightsaber)
    a_red_variation = items(:red_lightsaber)
    a_blue_variation = items(:blue_lightsaber)

    # Call the edit form.
    get :edit, :id => a_product.id
    assert_response :success
    assert_template 'edit'

    # Initially we should have three visible fields.
    assert_select "div#variation_container" do
      assert_select "div.variation", :count => 3
    end

    # Variations should be erased using ajax calls.
    xhr(:post, :remove_variation_ajax, :id => a_red_variation.id)
    xhr(:post, :remove_variation_ajax, :id => a_blue_variation.id)

    # At this point, the call doesn't issue a rjs statement, the field is just
    # hidden and the controller method executed, in the end the variation should
    # not be in the database.

    assert_equal a_product.variations.count, 1
  end


  # Test if we can remove images using ajax calls.
  def test_should_remove_image
    login_as :admin

    a_product = items(:lightsaber)
    a_red_image = a_product.images[0]
    a_blue_image = a_product.images[1]

    # Call the edit form.
    get :edit, :id => a_product.id
    assert_response :success
    assert_template 'edit'

    # Initially we should have three visible fields.
    assert_select "ul#image_list" do
      assert_select "li", :count => 3
    end

    # Images should be erased using ajax calls.
    xhr(:post, :remove_image_ajax, :id => a_red_image.id)
    xhr(:post, :remove_image_ajax, :id => a_blue_image.id)

    # At this point, the call doesn't issue a rjs statement, the field is just
    # hidden and the controller method executed, in the end the variation should
    # not be in the database.

    assert_equal a_product.images.count, 1
  end


  # Test if a new html chunk will be rendered using ajax, to be possible to
  # add another variation.
  def test_should_add_variation
    login_as :admin

    # Call the new form.
    get :new
    assert_response :success
    assert_template 'new'
    
    # Initially we should have no fields.
    assert_select "div#variation_container" do
      assert_select "div.variation", :count => 0
    end

    # Variation fields should be aded using ajax calls.
    xhr(:post, :add_variation_ajax)
    
    # We should have one field inserted using a rjs statement.
    assert_select_rjs "variation_container" do
      assert_select "div.variation", :count => 1
    end
  end


  # Test if we can remove a product.
  def test_should_remove_product
    login_as :admin

    a_product = items(:lightsaber)
    a_red_variation = items(:red_lightsaber)
    a_blue_variation = items(:blue_lightsaber)

    post :destroy, :id => a_product.id
    assert_response :redirect
    assert_redirected_to :action => :list

    # We should not find the product or its variations anymore.
    assert_raise(ActiveRecord::RecordNotFound) {
      Product.find(a_product.id)
    }
    assert_raise(ActiveRecord::RecordNotFound) {
      Variation.find(a_red_variation.id)
    }
    assert_raise(ActiveRecord::RecordNotFound) {
      Variation.find(a_blue_variation.id)
    }
  end


  # Test if we can update image ranks using ajax.
  def test_should_update_image_rank
    login_as :admin

    a_product = items(:lightsaber)
    
    # Product images in the images relation are already ordered by rank.
    position1 = a_product.images[0]
    position2 = a_product.images[1]
    position3 = a_product.images[2]

    # Call the edit form.
    get :edit, :id => a_product.id
    assert_response :success
    assert_template 'edit'

    # Initially we should have three visible fields.
    assert_select "ul#image_list" do
      assert_select "li", :count => 3
    end

    # Images should be ordered using ajax calls.
    xhr(:post, :update_image_rank_ajax, :id => a_product.id, :image_list => [position2.id, position1.id, position3.id])
    #puts "#{@response.body}"
 
    # At this point, the call doesn't issue a rjs statement, the fields are just
    # sorted and the controller method executed, it spits a highlight command too,
    # in the end the images should be ranked in another way.

    # Reload it an see if the order changed.
    a_product.reload
    # Product images in the images relation are already ordered by rank.
    new_position1 = a_product.images[0]
    new_position2 = a_product.images[1]
    new_position3 = a_product.images[2]

    # Compare the positions.
    assert_equal new_position1, position2
    assert_equal new_position2, position1
    assert_equal new_position3, position3
  end


  # TODO: Get rid of this method if it will not be used.
  # I have no idea where this is/was used.
  # Test if we can get rendered a partial passing a product and a list of tags.
  def test_should_get_tags
    login_as :admin

    a_product = items(:lightsaber)
    a_partial = "tag_list_form_row"
    
    # Call the get_tags action.
    get :get_tags, :id => a_product.id, :partial_name => a_partial
    assert_response :success
    assert_template '_tag_list_form_row'
    assert assigns(:product)

    # Do it again without an id.
    get :get_tags, :partial_name => a_partial
    assert_response :success
    assert_template '_tag_list_form_row'
    assert assigns(:product)
  end


  # Test if a new valid product will be saved, but create everything that can be
  # created together, images, related products, tags, variations, etc.
  def test_should_save_new_product_with_a_lot_of_stuff
    login_as :admin

    # Call the new form.
    get :new
    assert_response :success
    assert_template 'new'
    
    shrub1 = fixture_file_upload("/files/shrub1.jpg", 'image/jpeg')
    shrub2 = fixture_file_upload("/files/shrub2.jpg", 'image/jpeg')
    lightsabers_upload = fixture_file_upload("/files/lightsabers.jpg", 'image/jpeg')
    lightsaber_blue_upload = fixture_file_upload("/files/lightsaber_blue.jpg", 'image/jpeg')
    lightsaber_green_upload = fixture_file_upload("/files/lightsaber_green.jpg", 'image/jpeg')
    lightsaber_red_upload = fixture_file_upload("/files/lightsaber_red.jpg", 'image/jpeg')

    post :save,
    :product => {
      :code => "SHRUBBERY",
      :name => "Shrubbery",
      :description => "A shrubbery. One that looks nice, and is not too expensive. Perfect for a knight who say Ni.",
      :price => 90.50,
      :date_available => "2007-12-01 00:00",
      :quantity => 38,
      :size_width => 24,
      :size_height => 24,
      :size_depth => 12,
      :weight => 21.52,
      :related_product_suggestion_names => ["", "", "", "", ""],
      :tag_ids => ["", ""]
    },
    :image => [ {
        :image_data_temp => "",
        :image_data => shrub1
      }, {
        :image_data_temp => "",
        :image_data => shrub2
      }, {
        :image_data_temp => "",
        :image_data => lightsabers_upload
      }, {
        :image_data_temp => "",
        :image_data => lightsaber_blue_upload
      }, {
        :image_data_temp => "",
        :image_data => lightsaber_green_upload
      }, {
        :image_data_temp => "",
        :image_data => ""
    } ],
    :download => [
      {
        :download_data_temp => '',
        :download_data => lightsaber_red_upload
      }
    ]
    
    # If saved we should be redirected to edit form. 
    assert_response :redirect
    assert_redirected_to :action => :edit
    
    # Verify that the product and everything else are there.
    a_product = Product.find_by_code('SHRUBBERY')
    assert_not_nil a_product 
    assert_equal 5, a_product.images.count
    assert_equal 5, a_product.product_images.count
    assert_equal 1, a_product.downloads.count

    # Clean up system dir.
    a_product.images.destroy_all
    a_product.downloads.destroy_all
    
    a_product.reload

    # Verify that the product and everything else are there.
    assert_equal 0, a_product.images.count
    assert_equal 0, a_product.product_images.count
    assert_equal 0, a_product.downloads.count

  end

end
