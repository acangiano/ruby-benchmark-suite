require File.dirname(__FILE__) + '/../test_helper'

class PreferenceTest < ActiveSupport::TestCase
  fixtures :preferences


  # TODO: Should this method be here?
  # The responsability of initialize preferences shouldn't be of other module?
  def test_should_init_mail_settings
    assert Preference.init_mail_settings
  end
  
  
  # TODO: Should this method be here?
  # The responsability of saving preferences isn't of the controller?
  # A preference should just represent one instance of preferences?
  def test_should_save_settings
    prefs = {
      "store_name" => "Substruct",
      "store_handling_fee" => "0.00",
      "store_use_inventory_control"=>"1"
    }
    assert Preference.save_settings(prefs)
  end


  # Here we verify if a preference is true.
  def test_should_verify_if_is_true
    a_preference = preferences(:store_use_inventory_control)
    assert a_preference.is_true?

    a_preference = preferences(:store_require_login)
    assert !a_preference.is_true?
  end


end