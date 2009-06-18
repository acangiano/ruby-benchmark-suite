require File.dirname(__FILE__) + '/../test_helper'

class PromotionTest < ActiveSupport::TestCase
  fixtures :items, :promotions


  # Test if a valid promotion can be created with success.
  def test_should_create_promotion
    a_promotion = Promotion.new
    
    a_promotion.code = "NUCLEAR_REBATE"
    a_promotion.description = "U$ 50.00 discount, just today."
    a_promotion.discount_type = 1
    a_promotion.discount_amount = 50
    a_promotion.item = items(:uranium_portion)
    a_promotion.start = Time.now
    a_promotion.end = Time.now + 1.day
  
    assert a_promotion.save
  end


  # Test if a promotion will have its code cleaned before saved.
  def test_should_have_a_clean_code_before_saved
    a_promotion = Promotion.new
    
    a_promotion.code = "NUCLEAR REBATE"
    a_promotion.description = "U$ 50.00 discount, just today."
    a_promotion.discount_type = 1
    a_promotion.discount_amount = 50
    a_promotion.item = items(:uranium_portion)
    a_promotion.start = Time.now
    a_promotion.end = Time.now + 1.day
  
    assert a_promotion.save
    a_promotion.reload
    assert_equal a_promotion.code, "NUCLEARREBATE"
  end


  # Test if a promotion can be found with success.
  def test_should_find_promotion
    a_promotion_id = promotions(:fixed_rebate).id
    assert_nothing_raised {
      Promotion.find(a_promotion_id)
    }
  end


  # Test if a promotion can be updated with success.
  def test_should_update_promotion
    a_promotion = promotions(:fixed_rebate)
    assert a_promotion.update_attributes(:description => 'Buying anything, get a U$ 5.00 discount, extended for one more day.')
  end


  # Test if a promotion can be destroyed with success.
  def test_should_destroy_promotion
    a_promotion = promotions(:fixed_rebate)
    a_promotion.destroy
    assert_raise(ActiveRecord::RecordNotFound) {
      Promotion.find(a_promotion.id)
    }
  end


  # Test if an invalid promotion really will NOT be created.
  def test_should_not_create_invalid_promotion
    a_promotion = Promotion.new
    assert !a_promotion.valid?
    assert a_promotion.errors.invalid?(:code)
    assert a_promotion.errors.invalid?(:description)
    # It defaults to 0, so it will never happen.
    # assert a_promotion.errors.invalid?(:discount_type)
    # It defaults to 0.0, so it will never happen.
    # assert a_promotion.errors.invalid?(:discount_amount)
    # A promotion must have a code, a description, a type and an amount.
    assert_equal "can't be blank", a_promotion.errors.on(:code)
    assert_equal "can't be blank", a_promotion.errors.on(:description)

    a_promotion.discount_type = 2
    # If the item_id is empty when discount_type is 2, it cannot be saved.
    assert !a_promotion.valid?
    assert a_promotion.errors.invalid?(:item_id)
    assert_equal "Please add an item for the 'Buy [n] get 1 free' promotion", a_promotion.errors.on(:item_id)
    
    a_promotion.code = "PERCENT_REBATE"
    assert !a_promotion.valid?
    assert a_promotion.errors.invalid?(:code)
    # A promotion must have an unique code.
    assert_equal "has already been taken", a_promotion.errors.on(:code)

    assert !a_promotion.save
  end


  # Test if a random unique code will be generated.
  def test_should_generate_random_unique_code
    sample_code = Promotion.generate_code
    assert_nil Promotion.find(:first, :conditions => ["code = ?", sample_code])
  end


  # Test if active promotions can be found.
  def test_should_find_any_active_promotion
    assert Promotion.any_active?
    promotions(:fixed_rebate).destroy
    promotions(:percent_rebate).destroy
    assert Promotion.any_active?
    promotions(:eat_more_stuff).destroy
    promotions(:minimum_rebate).destroy
    assert !Promotion.any_active?
  end


  # Test if a promotion is active.
  def test_should_discover_if_promotion_is_active
    assert promotions(:fixed_rebate).is_active?
    assert promotions(:percent_rebate).is_active?
    assert promotions(:eat_more_stuff).is_active?
    assert !promotions(:old_rebate).is_active?
  end


  # Test if we can associate a product using a suggestion name.
  def test_should_associate_product_using_suggestion_name
    a_promotion = promotions(:eat_more_stuff)
    
    assert_equal a_promotion.item, items(:small_stuff)
    
    a_promotion.product_name = items(:holy_grenade).suggestion_name
    a_promotion.save
    a_promotion.reload
    assert_equal a_promotion.item, items(:holy_grenade)
  end


  # Test if will not be associated a product using an invalid suggestion name.
  def test_should_not_associate_product_using_invalid_suggestion_name
    a_promotion = promotions(:eat_more_stuff)
    
    assert_equal a_promotion.item, items(:small_stuff)
    
    a_promotion.product_name = "ABC: BLA BLA BLA"
    assert_equal a_promotion.item_id, nil
  end


end
