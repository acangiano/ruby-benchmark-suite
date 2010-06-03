$: << '.'
require File.dirname(__FILE__) + '/../test_helper'

class AssetTest < ActiveSupport::TestCase


  # Test if an asset will be created, generate and get rid of its files properly and
  # be erased.
  def test_should_create_handle_and_destroy_assets
    text_asset = fixture_file_upload("/files/text_asset.txt", 'text/plain')

    an_asset = Asset.new
    an_asset.uploaded_data = text_asset
    assert an_asset.save
    
    # Assert that the file exists.
    assert File.exist?(an_asset.full_filename)

    # We must erase the record and its files by hand, just calling destroy.
    assert an_asset.destroy
    assert !File.exist?(an_asset.full_filename)
  end


end
