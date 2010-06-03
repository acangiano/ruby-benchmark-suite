$: << '.'
require File.dirname(__FILE__) + '/../test_helper'

class ImageTest < ActiveSupport::TestCase
  fixtures :items, :product_images, :user_uploads


  # Test if a valid image can be created with success.
  def test_should_create_image
    lightsabers_image = fixture_file_upload("/files/lightsabers.jpg", 'image/jpeg')

    an_image = Image.new
    an_image.uploaded_data = lightsabers_image
    assert an_image.save
    
    # We must erase the record and its files by hand, just calling destroy.
    assert an_image.destroy
  end


  # Test if an image can be associated with products.
  def test_should_associate_images
    a_product = items(:lightsaber)
    assert_equal a_product.images.count, 3

    lightsabers_image = fixture_file_upload("/files/lightsabers.jpg", 'image/jpeg')

    an_image = Image.new
    an_image.uploaded_data = lightsabers_image
    assert an_image.save
    
    a_product.images << an_image
    assert_equal a_product.images.count, 4
    
    # We must erase the record and its files by hand, just calling destroy.
    assert an_image.destroy
  end


  # Test if an image will generate and get rid of its files properly.
  def test_should_handle_files
    # make reference to four images.
    lightsabers_upload = fixture_file_upload("/files/lightsabers.jpg", 'image/jpeg')
    lightsaber_blue_upload = fixture_file_upload("/files/lightsaber_blue.jpg", 'image/jpeg')
    lightsaber_green_upload = fixture_file_upload("/files/lightsaber_green.jpg", 'image/jpeg')
    lightsaber_red_upload = fixture_file_upload("/files/lightsaber_red.jpg", 'image/jpeg')

    # Load them all and save.
    lightsabers_image = Image.new
    lightsabers_image.uploaded_data = lightsabers_upload
    assert lightsabers_image.save
    
    lightsaber_blue_image = Image.new
    lightsaber_blue_image.uploaded_data = lightsaber_blue_upload
    assert lightsaber_blue_image.save
    
    lightsaber_green_image = Image.new
    lightsaber_green_image.uploaded_data = lightsaber_green_upload
    assert lightsaber_green_image.save
    
    lightsaber_red_image = Image.new
    lightsaber_red_image.uploaded_data = lightsaber_red_upload
    assert lightsaber_red_image.save
    
    # Assert that all those files exists.
    assert File.exist?(lightsabers_image.full_filename)
    for thumb in lightsabers_image.thumbnails
      assert File.exist?(thumb.full_filename)
    end
    
    assert File.exist?(lightsaber_blue_image.full_filename)
    for thumb in lightsaber_blue_image.thumbnails
      assert File.exist?(thumb.full_filename)
    end

    assert File.exist?(lightsaber_green_image.full_filename)
    for thumb in lightsaber_green_image.thumbnails
      assert File.exist?(thumb.full_filename)
    end

    assert File.exist?(lightsaber_red_image.full_filename)
    for thumb in lightsaber_red_image.thumbnails
      assert File.exist?(thumb.full_filename)
    end

    # We must erase the records and its files by hand, just calling destroy.
    assert lightsabers_image.destroy
    assert lightsaber_blue_image.destroy
    assert lightsaber_green_image.destroy
    assert lightsaber_red_image.destroy
    
    
    # See if the files really was erased.
    for thumb in lightsabers_image.thumbnails
      assert !File.exist?(thumb.full_filename)
    end
    assert !File.exist?(lightsabers_image.full_filename)

    for thumb in lightsaber_blue_image.thumbnails
      assert !File.exist?(thumb.full_filename)
    end
    assert !File.exist?(lightsaber_blue_image.full_filename)

    for thumb in lightsaber_green_image.thumbnails
      assert !File.exist?(thumb.full_filename)
    end
    assert !File.exist?(lightsaber_green_image.full_filename)

    for thumb in lightsaber_red_image.thumbnails
      assert !File.exist?(thumb.full_filename)
    end
    assert !File.exist?(lightsaber_red_image.full_filename)
  end


end
