require File.dirname(__FILE__) + '/../test_helper'

class SectionTest < ActiveSupport::TestCase
  fixtures :sections, :content_nodes


  # Test if a valid section can be created with success.
  def test_should_create_section
    a_section = Section.new( :name => "New Section" )
  
    assert a_section.save
  end


  # Test if a section can be found with success.
  def test_should_find_section
    a_section_id = sections(:junk_food_news).id
    assert_nothing_raised {
      Section.find(a_section_id)
    }
  end


  # Test if a section can be updated with success.
  def test_should_update_section
    a_section = sections(:celebrity_pregnancies)
    assert a_section.update_attributes(:name => 'Celebrity News')
  end


  # Test if a section can be destroyed with success.
  def test_should_destroy_section
    a_section = sections(:celebrity_pregnancies)
    a_section.destroy
    assert_raise(ActiveRecord::RecordNotFound) {
      Section.find(a_section.id)
    }
  end


  # Test if an invalid section really will NOT be created.
  def test_should_not_create_invalid_section
    a_section = Section.new
    assert !a_section.valid?
    assert a_section.errors.invalid?(:name)
    # A section must have a name.
    assert_equal "can't be blank", a_section.errors.on(:name)
    a_section.name = "Junk Food News"
    assert !a_section.valid?
    assert a_section.errors.invalid?(:name)
    # A section must have an unique name.
    assert_equal "has already been taken", a_section.errors.on(:name)
    assert !a_section.save
  end


  # Test if sections can have parents.
  def test_should_have_parents
    my_own_tabloid = Section.new( :name => "My Own Tabloid" )
    annoying_paparazzi = Section.new( :name => "Annoying Paparazzi" )
    classified_ads = Section.new( :name => "Classified Ads" )
    
    my_own_tabloid.save
    
    my_own_tabloid.children << annoying_paparazzi
    my_own_tabloid.children << classified_ads

    assert_equal my_own_tabloid.children.count, 2
    my_own_tabloid.children.delete(annoying_paparazzi)
    assert_equal my_own_tabloid.children, [classified_ads]
  end


  # Find sections sorted alphanumerically.
  def test_should_find_alpha
    assert_equal sections(:celebrity_pregnancies, :junk_food_news, :prophecies, :pseudoscientific_claims, :usefull_news), Section.find_alpha
  end


  # Find parent sections ordered by rank.
  def test_should_find_ordered_parents
    assert_equal sections(:usefull_news, :junk_food_news, :prophecies), Section.find_ordered_parents
  end


  # Test if the content counter shows the quantity of content, and as a chache
  # that it will NOT update its content.
  def test_should_show_content_count
    silent_birth = content_nodes(:silent_birth)
    pigasus_awards = content_nodes(:pigasus_awards)
    tinkerbel_pregnant = content_nodes(:tinkerbel_pregnant)
    
    a_new_section = Section.new( :name => "New" )
    
    a_new_section.save
    a_new_section.content_nodes << silent_birth
    a_new_section.content_nodes << pigasus_awards
    a_new_section.content_nodes << tinkerbel_pregnant
    assert_equal a_new_section.content_count, 3
    a_new_section.content_nodes.clear
    assert_equal a_new_section.content_count, 3
  end


end