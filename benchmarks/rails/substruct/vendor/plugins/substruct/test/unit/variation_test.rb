$: << '.'
require File.dirname(__FILE__) + '/../test_helper'

class VariationTest < ActiveSupport::TestCase
  # If the model was inherited from another model, the fixtures must be the
  # base model, as it will be used as the table name.
  fixtures :items


  # Test if the fixtures are of the proper type.
  def test_item_should_be_of_proper_type
    assert_kind_of Variation, items(:red_lightsaber)
    assert_kind_of Variation, items(:blue_lightsaber)
    assert_kind_of Variation, items(:green_lightsaber)
    assert_kind_of Variation, items(:grey_coat)
    assert_kind_of Variation, items(:beige_coat)
    assert_kind_of Variation, items(:small_stuff)
  end


  # Test if an orphaned variation will NOT be saved.
  def test_should_not_save_orphaned_variation
    # Create a variation.
    a_variation = Variation.new
    a_variation.code = "BIG_STUFF"
    a_variation.name = "Big"
    a_variation.price = 5.75
    a_variation.quantity = 500

    # Don't assign the variation to anything and try to save it. The callbak
    # method update_parent_quantity should try to access self.product.variations,
    # but product is nil and variations doesn't exist.
    assert_raise(NoMethodError) {
      a_variation.save
    }
  end


  # Test if a valid variation can be assigned and saved with success.
  def test_should_assign_and_save_variation
    # Load a product.
    a_product = items(:the_stuff)
    assert_nothing_raised {
      Product.find(a_product.id)
    }

    # Create a variation.
    a_variation = Variation.new
    a_variation.code = "BIG_STUFF"
    a_variation.name = "Big"
    a_variation.price = 5.75
    a_variation.quantity = 500

    # Assign the variation to its respective product and save the variation.  
    assert a_product.variations << a_variation
    assert a_variation.save
    
    # Verify if a default date is beeing assigned to date_available.
    assert_equal a_variation.date_available, Date.today
  end


  # Test if a variation can be found with success.
  def test_should_find_variation
    a_variation_id = items(:small_stuff).id
    assert_nothing_raised {
      Variation.find(a_variation_id)
    }
  end


  # Test if a variation can be updated and if the product will be updated too.
  def test_should_update_variation_and_product
    a_variation = items(:small_stuff)
    assert a_variation.update_attributes(:name => 'Very Small')
    
    # Load the variation's product.
    a_product = a_variation.product
    variation_quantity = a_product.variation_quantity
    assert a_variation.update_attributes(:quantity => a_variation.quantity + 2)
    assert_equal a_product.variation_quantity, variation_quantity + 2 
  end


  # Test if a variation can be destroyed and if its product will know about that.
  def test_should_destroy_variation
    a_variation = items(:small_stuff)
    variations_counter = a_variation.product.variations.count
    a_variation.destroy
    assert_raise(ActiveRecord::RecordNotFound) {
      Variation.find(a_variation.id)
    }
    assert_equal a_variation.product.variations.count, variations_counter - 1 
  end


  # Test if an invalid variation really will NOT be created.
  def test_should_not_create_invalid_variation
    a_variation = Variation.new
    a_variation.product = items(:the_stuff)
    assert !a_variation.valid?
    assert a_variation.errors.invalid?(:code)

#    # TODO: A variation cannot be considered to having a valid name just because it is associated with a product.
#    assert a_variation.errors.invalid?(:name)

    # A variation must have a code and a name.
    assert_equal "can't be blank", a_variation.errors.on(:code)

#    # TODO: If the name wasn't specified it should say it.
#    assert_equal "can't be blank", a_variation.errors.on(:name)

    # Choosing an already taken variation code.
    a_variation.code = "STUFF"
    assert !a_variation.valid?
    assert a_variation.errors.invalid?(:code)
    # A variation must have an unique code.
    assert_equal "has already been taken", a_variation.errors.on(:code)

    assert !a_variation.save
  end


  # Test if the variation images points to product images as variations can't
  # have their own images.
  def test_should_point_its_images_to_product_images
    a_variation = items(:small_stuff)
    assert_equal a_variation.images, a_variation.product.images
  end


  # Test if the variation name is concatenated with the product name.
  def test_should_concatenate_product_name
    a_variation = items(:small_stuff)
    assert_equal a_variation.name, "#{a_variation.product.name} - #{a_variation.short_name}" 
  end


end
