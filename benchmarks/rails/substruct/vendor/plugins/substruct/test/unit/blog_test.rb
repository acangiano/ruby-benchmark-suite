$: << '.'
require File.dirname(__FILE__) + '/../test_helper'

class BlogTest < ActiveSupport::TestCase
  fixtures :content_nodes


  # Find latest blog post.
  def test_should_find_latest
    assert_equal content_nodes(:silent_birth), Blog.find_latest
  end


end