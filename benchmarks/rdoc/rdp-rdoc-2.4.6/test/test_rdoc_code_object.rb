require 'rubygems'
require 'minitest/unit'
require 'test/xref_test_case'
require 'rdoc/code_object'

class TestRDocCodeObject < XrefTestCase

  def setup
    super

    @co = RDoc::CodeObject.new
  end

  def test_initialize
    assert @co.document_self, 'document_self'
    assert @co.document_children, 'document_children'
    refute @co.force_documentation, 'force_documentation'
    refute @co.done_documenting, 'done_documenting'
    assert_equal nil, @co.comment, 'comment is nil'
  end

  def test_comment_equals
    @co.comment = ''

    assert_equal nil, @co.comment

    @co.comment = 'I am a comment'

    assert_equal 'I am a comment', @co.comment
  end

  def test_document_children_equals
    @co.document_children = false
    refute @co.document_children

    @c2.document_children = false
    assert_empty @c2.classes
  end

  def test_document_self_equals
    @co.document_self = false
    refute @co.document_self

    @c1.document_self = false
    assert_empty @c1.method_list
  end

  def test_parent_file_name
    assert_equal '(unknown)', @co.parent_file_name
    assert_equal 'xref_data.rb', @c1.parent_file_name
  end

  def test_parent_name
    assert_equal '(unknown)', @co.parent_name
    assert_equal 'xref_data.rb', @c1.parent_name
    assert_equal 'C2', @c2_c3.parent_name
  end

  def test_start_doc
    @co.document_self = false
    @co.document_children = false

    @co.start_doc

    assert @co.document_self
    assert @co.document_children
  end

  def test_stop_doc
    @co.document_self = true
    @co.document_children = true

    @co.stop_doc

    refute @co.document_self
    refute @co.document_children
  end

end

