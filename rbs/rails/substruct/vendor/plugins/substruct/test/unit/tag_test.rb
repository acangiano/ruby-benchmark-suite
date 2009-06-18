require File.dirname(__FILE__) + '/../test_helper'

class TagTest < ActiveSupport::TestCase
  fixtures :tags, :items


  # Test if a valid tag can be created with success.
  def test_should_create_tag
    a_tag = Tag.new( :name => "Food" )
  
    assert a_tag.save
  end


  # Test if a tag can be found with success.
  def test_should_find_tag
    a_tag_id = tags(:weapons).id
    assert_nothing_raised {
      Tag.find(a_tag_id)
    }
  end


  # Test if a tag can be updated with success.
  def test_should_update_tag
    a_tag = tags(:weapons)
    assert a_tag.update_attributes(:name => 'Powerfull Weapons')
  end


  # Test if a tag can be destroyed with success.
  def test_should_destroy_tag
    a_tag = tags(:weapons)
    a_tag.destroy
    assert_raise(ActiveRecord::RecordNotFound) {
      Tag.find(a_tag.id)
    }
  end


  # Test if an invalid tag really will NOT be created.
  def test_should_not_create_invalid_tag
    a_tag = Tag.new
    assert !a_tag.valid?
    assert a_tag.errors.invalid?(:name)
    # A tag must have a name.
    assert_equal "can't be blank", a_tag.errors.on(:name)
    a_tag.name = "Books"
    assert !a_tag.valid?
    assert a_tag.errors.invalid?(:name)
    # A tag must have an unique name.
    assert_equal "has already been taken", a_tag.errors.on(:name)
    assert !a_tag.save
  end


  # Test if tags can have parents.
  def test_should_have_parents
    a_food_tag = Tag.new( :name => "Food" )
    a_sweet_tag = Tag.new( :name => "Sweet" )
    a_salty_tag = Tag.new( :name => "Salty" )
    
    a_food_tag.save
    
    a_food_tag.children << a_sweet_tag
    a_food_tag.children << a_salty_tag

    assert_equal a_food_tag.children.count, 2
    a_food_tag.children.delete(a_sweet_tag)
    assert_equal a_food_tag.children, [a_salty_tag]
  end


  # Find tags sorted alphanumerically.
  def test_should_find_alpha
    assert_equal tags(:books, :fluffy, :laser_beam, :mass_destruction, :medieval, :on_sale, :weapons, :weird), Tag.find_alpha
  end


  # Find parent tags ordered by rank.
  def test_should_find_ordered_parents
    assert_equal tags(:books, :fluffy, :weapons, :weird, :on_sale), Tag.find_ordered_parents
  end


  # Test if the product counter shows the quantity of products, and as a chache
  # that it will NOT update its content.
  def test_should_show_product_count
    a_coat = items(:chinchilla_coat)
    a_towel = items(:towel)
    a_stuff = items(:the_stuff)
    
    a_new_tag = Tag.new( :name => "New" )
    
    a_new_tag.save
    a_new_tag.products << a_coat
    a_new_tag.products << a_towel
    a_new_tag.products << a_stuff
    assert_equal a_new_tag.product_count, 3
    a_new_tag.products.clear
    assert_equal a_new_tag.product_count, 3
  end


  # Pick all products associated with all tag ids passed, and return the tag
  # objects that any of these products are associated with too but wasnt passed.
  def test_should_find_related_tags
    assert_same_elements tags(:mass_destruction, :on_sale, :weird), Tag.find_related_tags([tags(:weapons).id])
    assert_same_elements [], Tag.find_related_tags([tags(:books).id])
  end


end