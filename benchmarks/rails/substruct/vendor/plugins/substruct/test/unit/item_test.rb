$: << '.'
require File.dirname(__FILE__) + '/../test_helper'

class ItemTest < ActiveSupport::TestCase


  # Test the name suggested for JS autocompletion.
  def test_suggestion_name
    an_item = Item.new
    an_item.code = "SHRUBBERY"
    an_item.name = "Shrubbery"
    # An item must suggest a name in the form "code: name".
    assert_equal "SHRUBBERY: Shrubbery", an_item.suggestion_name
    an_item.code = "CHANGED"
    an_item.name = "Another name"
    # An item must suggest a name in the form "code: name".
    assert_equal "CHANGED: Another name", an_item.suggestion_name
  end


end
