$: << '.'
require File.dirname(__FILE__) + '/../test_helper'

class OrderTest < ActiveSupport::TestCase
  fixtures :all
  
  def setup
    @santa_order = orders(:santa_next_christmas_order)
  end
  
  def test_associations
    assert_working_associations
    assert_not_nil @santa_order.customer
  end

  def test_can_save_cart_order
    order = Order.create
    assert !order.new_record?
    cart_status_code = OrderStatusCode.find_by_name('CART')
    assert_equal order.order_status_code, cart_status_code, "Order wasn't initialized to CART status code."
  end

  # Test if a valid order can be created with success.
  def test_create_order
    an_order_line_item = OrderLineItem.for_product(items(:small_stuff))

    an_order = Order.new
    
    an_order.order_line_items << an_order_line_item
    an_order.tax = 0.0
    an_order.product_cost = 1.25
    an_order.created_on = 1.day.ago
    an_order.shipping_address = order_addresses(:uncle_scrooge_address)
    an_order.order_user = order_users(:uncle_scrooge)
    an_order.billing_address = order_addresses(:uncle_scrooge_address)
    an_order.shipped_on = "" 
    an_order.order_shipping_type = order_shipping_types(:ups_xp_critical)
    an_order.promotion_id = 0
    an_order.notes = '<p>Order completed.<br/><span class="info">[04-04-08 05:18 PM]</span></p>'
    an_order.referer = "" 
    an_order.shipping_cost = 30.0
    an_order.order_number = Order.generate_order_number
    an_order.order_account = order_accounts(:uncle_scrooge_account)
    an_order.auth_transaction_id = "" 
    an_order.order_status_code = order_status_codes(:ordered_paid_to_ship)

    assert an_order.save
  end


  # Test if an order can be found with success.
  def test_find_order
    an_order_id = orders(:santa_next_christmas_order).id
    assert_nothing_raised {
      Order.find(an_order_id)
    }
  end


  # Test if an order can be updated with success.
  def test_update_order
    an_order = orders(:santa_next_christmas_order)
    assert an_order.update_attributes(:notes => '<p>Order completed.<br/><span class="info">[04-04-08 05:18 PM]</span><br/>New note.</p>')
  end


  # Test if an order can be destroyed with success.
  def test_destroy_order
    an_order = orders(:santa_next_christmas_order)
    an_order.destroy
    assert_raise(ActiveRecord::RecordNotFound) {
      Order.find(an_order.id)
    }
  end


  # Test if an invalid order really will NOT be created.
  def dont_test_not_create_invalid_order
#    # TODO: By now theres no way to make an order invalid, it accepts any blank values and saves it.
#    an_order = Order.new
#    assert !an_order.valid?
#    assert an_order.errors.invalid?(:order_number)
#    # An order must have a number.
#    assert_equal "can't be blank", an_order.errors.on(:order_number)
#    assert !an_order.save
  end


  # Test if the product cost is being set before save.
  def test_set_product_cost
    an_order_line_item = OrderLineItem.for_product(items(:small_stuff))

    an_order = Order.new
    
    an_order.order_line_items << an_order_line_item
    an_order.tax = 0.0
    an_order.created_on = 1.day.ago
    an_order.shipping_address = order_addresses(:uncle_scrooge_address)
    an_order.order_user = order_users(:uncle_scrooge)
    an_order.billing_address = order_addresses(:uncle_scrooge_address)
    an_order.shipped_on = "" 
    an_order.order_shipping_type = order_shipping_types(:ups_xp_critical)
    an_order.promotion_id = 0
    an_order.notes = '<p>Order completed.<br/><span class="info">[04-04-08 05:18 PM]</span></p>'
    an_order.referer = "" 
    an_order.shipping_cost = 30.0
    an_order.order_number = Order.generate_order_number
    an_order.order_account = order_accounts(:uncle_scrooge_account)
    an_order.auth_transaction_id = "" 
    an_order.order_status_code = order_status_codes(:ordered_paid_to_ship)

    assert an_order.save
    an_order.reload
    
    assert_equal an_order.product_cost, an_order_line_item.total
  end


  # Test if a promotion will be processed.
  # OK # FIXME: promo.minimum_cart_value is being compared with the order total value.
  # OK # FIXME: promo.minimum_cart_value is being compared before get rid of the old promotion.
  # OK # FIXME: oli.unit_price uses order total value when using a percent promotion.
  # OK # FIXME: The previous promotion line item isn't being properly deleted.
  # TODO: The method doesn't do only what its name says.
  # TODO: Why log every time a new OrderLineItem is created?
  # TODO: oli.item_id = promo.item_id is an ugly hack, setting an order item to empty in some situations.
  # The problem of using the order total value is that it varies at different stages of the flow
  # if a shipping service was already choosed it will be different, executing the checkout, choosing a
  # shipping service, coming back adding another product and doing checkout again it will be different
  # etc.
  def test_set_promo_code
    a_coat_line_item = OrderLineItem.for_product(items(:grey_coat))
    a_stuff_line_item = OrderLineItem.for_product(items(:small_stuff))

    # Create an order.
    an_order = Order.new
    
    an_order.order_line_items << a_coat_line_item
    an_order.order_line_items << a_stuff_line_item
    an_order.tax = 0.0
    an_order.created_on = 1.day.ago
    an_order.shipping_address = order_addresses(:uncle_scrooge_address)
    an_order.order_user = order_users(:uncle_scrooge)
    an_order.billing_address = order_addresses(:uncle_scrooge_address)
    an_order.shipped_on = "" 
    an_order.order_shipping_type = order_shipping_types(:ups_xp_critical)
    an_order.promotion_id = 0
    an_order.notes = '<p>Order completed.<br/><span class="info">[04-04-08 05:18 PM]</span></p>'
    an_order.referer = "" 
    an_order.shipping_cost = 30.0
    an_order.order_number = Order.generate_order_number
    an_order.order_account = order_accounts(:uncle_scrooge_account)
    an_order.auth_transaction_id = "" 
    an_order.order_status_code = order_status_codes(:ordered_paid_to_ship)

    assert an_order.save
    
    # Save the total value before set any promotion.
    initial_order_total = an_order.total
    initial_line_items_total = an_order.line_items_total
    
    # Test a fixed rebate.
    a_fixed_rebate = promotions(:fixed_rebate)
    an_order.promotion_code = a_fixed_rebate.code
    # Saving it, sets the promo code and product cost.
    assert an_order.save
    assert_equal an_order.total, initial_order_total - a_fixed_rebate.discount_amount, "Fixed rebate verification error."
    

    # Test a percent rebate.
    a_percent_rebate = promotions(:percent_rebate)
    an_order.promotion_code = a_percent_rebate.code
    # Saving it, sets the promo code and product cost.
    assert an_order.save
    assert_equal an_order.total, initial_order_total - (initial_line_items_total * (a_percent_rebate.discount_amount/100)), "Percent rebate verification error."


    # Test a fixed rebate with a minimum cart value, after any previous promotion.
    a_minimum_rebate = promotions(:minimum_rebate)
    an_order.promotion_code = a_minimum_rebate.code
    # Saving it, sets the promo code and product cost.
    assert an_order.save
    assert_equal an_order.total, initial_order_total - a_fixed_rebate.discount_amount, "Fixed rebate with minimum cart value verification error."

    
    # Save the quantity before set the promotion.
    initial_line_item_quantity = an_order.order_line_items.find_by_name(a_stuff_line_item.name).quantity

    # Test a get 1 more free promotion.
    a_1_more_free_promotion = promotions(:eat_more_stuff)
    an_order.promotion_code = a_1_more_free_promotion.code
    # Saving it, sets the promo code and product cost.
    an_order.save
    assert_equal an_order.order_line_items.find_by_name(a_stuff_line_item.name).quantity, initial_line_item_quantity
    assert_equal an_order.order_line_items.find_by_name(a_1_more_free_promotion.description).quantity, a_1_more_free_promotion.discount_amount
    # order_line_items.name return the item name but order_line_items.find_by_name finds using the line item real name (the promotion description).
    assert_not_equal an_order.order_line_items.find_by_name(a_stuff_line_item.name), an_order.order_line_items.find_by_name(a_1_more_free_promotion.description)
  end


  # Test if it will properly delete a previous promotion before apply a new one.
  def test_delete_previous_promotion_line_item
    a_coat_line_item = OrderLineItem.for_product(items(:grey_coat))
    a_stuff_line_item = OrderLineItem.for_product(items(:small_stuff))

    # Create an order.
    an_order = Order.new
    
    an_order.order_line_items << a_coat_line_item
    an_order.order_line_items << a_stuff_line_item
    an_order.tax = 0.0
    an_order.created_on = 1.day.ago
    an_order.shipping_address = order_addresses(:uncle_scrooge_address)
    an_order.order_user = order_users(:uncle_scrooge)
    an_order.billing_address = order_addresses(:uncle_scrooge_address)
    an_order.shipped_on = "" 
    an_order.order_shipping_type = order_shipping_types(:ups_xp_critical)
    an_order.promotion_id = 0
    an_order.notes = '<p>Order completed.<br/><span class="info">[04-04-08 05:18 PM]</span></p>'
    an_order.referer = "" 
    an_order.shipping_cost = 30.0
    an_order.order_number = Order.generate_order_number
    an_order.order_account = order_accounts(:uncle_scrooge_account)
    an_order.auth_transaction_id = "" 
    an_order.order_status_code = order_status_codes(:ordered_paid_to_ship)

    assert an_order.save

    
    # Test a fixed rebate.
    a_fixed_rebate = promotions(:fixed_rebate)
    an_order.promotion_code = a_fixed_rebate.code
    # Saving it, sets the promo code and product cost.
    assert an_order.save
    # Assert the promotion is there.
    assert_equal an_order.order_line_items.find_by_name(a_fixed_rebate.description).name, a_fixed_rebate.description, "The fixed rebate wasn't added properly."

    # Test a percent rebate.
    a_percent_rebate = promotions(:percent_rebate)
    an_order.promotion_code = a_percent_rebate.code
    # Saving it, sets the promo code and product cost.
    assert an_order.save
    # Assert the promotion is there.
    assert_equal an_order.order_line_items.find_by_name(a_percent_rebate.description).name, a_percent_rebate.description, "The percent rebate wasn't added properly."

    # Assert the previous promotion is NOT there.
    assert_equal an_order.order_line_items.find_by_name(a_fixed_rebate.description), nil, "The fixed rebate is still there."

    # Test a get 1 more free promotion.
    a_1_more_free_promotion = promotions(:eat_more_stuff)
    an_order.promotion_code = a_1_more_free_promotion.code
    # Saving it, sets the promo code and product cost.
    assert an_order.save
    # Assert the promotion is there.
    assert an_order.order_line_items.find_by_name(a_1_more_free_promotion.description), "The 1 more free promotion wasn't added properly."

    # Assert the previous promotion is NOT there.
    assert_equal an_order.order_line_items.find_by_name(a_percent_rebate.description), nil, "The percent rebate is still there."

    # Test a fixed rebate again.
    a_fixed_rebate = promotions(:fixed_rebate)
    an_order.promotion_code = a_fixed_rebate.code
    # Saving it, sets the promo code and product cost.
    assert an_order.save
    # Assert the promotion is there.
    assert an_order.order_line_items.find_by_name(a_fixed_rebate.description), "The fixed rebate wasn't added properly."

    # Assert the previous promotion is NOT there.
    assert_equal an_order.order_line_items.find_by_name(a_1_more_free_promotion.description), nil, "The 1 more free promotion is still there."

    # Test a get 1 more free promotion again but this time without the correspondent item.
    an_order.order_line_items.delete(a_stuff_line_item)
    assert an_order.save
    
    a_1_more_free_promotion = promotions(:eat_more_stuff)
    an_order.promotion_code = a_1_more_free_promotion.code
    # Saving it, sets the promo code and product cost.
    assert an_order.save
    # Assert the promotion is there.
    assert_equal an_order.order_line_items.find_by_name(a_1_more_free_promotion.description), nil, "The 1 more free promotion should NOT be added here."

    # Assert the previous promotion is NOT there.
    assert_equal an_order.order_line_items.find_by_name(a_fixed_rebate.description), nil, "The fixed rebate is still there."

    # Test a percent rebate, again.
    a_percent_rebate = promotions(:percent_rebate)
    an_order.promotion_code = a_percent_rebate.code
    # Saving it, sets the promo code and product cost.
    assert an_order.save
    # Assert the promotion is there.
    assert_equal an_order.order_line_items.find_by_name(a_percent_rebate.description).name, a_percent_rebate.description, "The percent rebate wasn't added properly."

    # Assert the correct line items length in the end.
    assert_equal an_order.order_line_items.length, 2, "There's something wrong with the line items length."
  end

  
  # Test if orders can found using the search method.
  def test_search_order
    # Test a search.
    assert_same_elements Order.search("Santa"), orders(:santa_next_christmas_order, :an_order_on_cart, :an_order_to_charge, :an_order_on_hold_payment_failed, :an_order_on_hold_awaiting_payment, :an_order_ordered_paid_shipped, :an_order_sent_to_fulfillment, :an_order_cancelled, :an_order_returned)
    # Test with changed case. (it should be case insensitive)
    assert_same_elements Order.search("santa"), orders(:santa_next_christmas_order, :an_order_on_cart, :an_order_to_charge, :an_order_on_hold_payment_failed, :an_order_on_hold_awaiting_payment, :an_order_ordered_paid_shipped, :an_order_sent_to_fulfillment, :an_order_cancelled, :an_order_returned)
    # Test a select count.
    assert_equal Order.search("santa", true), 9
  end


  # Test if orders can found by country using the search method.
  def test_search_order_by_country
    # Test a search.
    assert_same_elements Order.find_by_country(countries(:US).id), orders(:santa_next_christmas_order, :an_order_on_cart, :an_order_to_charge, :an_order_on_hold_payment_failed, :an_order_on_hold_awaiting_payment, :an_order_ordered_paid_shipped, :an_order_sent_to_fulfillment, :an_order_cancelled, :an_order_returned)
    # Test a select count.
    assert_equal Order.find_by_country(countries(:US).id, true), 9
  end

  
  # Test if a random unique number will be generated.
  def test_generate_random_unique_order_number
    sample_number = Order.generate_order_number
    assert_nil Order.find(:first, :conditions => ["order_number = ?", sample_number])
  end
  
  
  # Test if the sales totals for a given year will be generated.
  def test_get_sales_totals_for_year
    sales_totals = Order.get_totals_for_year(Date.today.year)
    an_order = orders(:santa_next_christmas_order)
    a_month = an_order.created_on.month
    sales_totals[a_month][0] = 1
    sales_totals[a_month][1] = an_order.product_cost
    sales_totals[a_month][2] = an_order.tax
    sales_totals[a_month][3] = an_order.shipping_cost
  end

  
  # Test if a csv file with a list of orders will be generated.
  def test_get_csv_for_orders
    # We don't have more than one order to test now.
    an_order = orders(:santa_next_christmas_order)

    # Create a new order, with a blank shipping type, just to cover a comparison in the method.
    another_order_line_item = OrderLineItem.for_product(items(:small_stuff))

    another_order = Order.new
    
    another_order.order_line_items << another_order_line_item
    another_order.tax = 0.0
    another_order.product_cost = 1.25
    another_order.created_on = 1.day.ago
    another_order.shipping_address = order_addresses(:uncle_scrooge_address)
    another_order.order_user = order_users(:uncle_scrooge)
    another_order.billing_address = order_addresses(:uncle_scrooge_address)
    another_order.shipped_on = "" 
    another_order.promotion_id = 0
    another_order.notes = '<p>Order completed.<br/><span class="info">[04-04-08 05:18 PM]</span></p>'
    another_order.referer = "" 
    another_order.shipping_cost = 30.0
    another_order.order_number = Order.generate_order_number
    another_order.order_account = order_accounts(:uncle_scrooge_account)
    another_order.auth_transaction_id = "" 
    another_order.order_status_code = order_status_codes(:cart)

    assert another_order.save
    
    # Test the CSV.
    csv_string = Order.get_csv_for_orders([an_order, another_order])
    csv_array = FasterCSV.parse(csv_string)

    # Test if the header is right.
    assert_equal csv_array[0], [
      "OrderNumber", "Company", "ShippingType", "Date", 
      "BillLastName", "BillFirstName", "BillAddress", "BillCity", 
      "BillState", "BillZip", "BillCountry", "BillTelephone", 
      "ShipLastName", "ShipFirstName", "ShipAddress", "ShipCity", 
      "ShipState", "ShipZip", "ShipCountry", "ShipTelephone",
      "Item1", "Quantity1", "Item2", "Quantity2", "Item3", "Quantity3", "Item4", "Quantity4",
      "Item5", "Quantity5", "Item6", "Quantity6", "Item7", "Quantity7", "Item8", "Quantity8",
      "Item9", "Quantity9", "Item10", "Quantity10", "Item11", "Quantity11", "Item12", "Quantity12",
      "Item13", "Quantity13", "Item14", "Quantity14", "Item15", "Quantity15", "Item16", "Quantity16"
    ]

   order_arr = []
   orders_list_arr = []
    
    # Test if an order is right.
    for order in [an_order, another_order]
      bill = order.billing_address
      ship = order.shipping_address
      pretty_date = order.created_on.strftime("%m/%d/%y")
      if !order.order_shipping_type.nil?
        ship_code = order.order_shipping_type.code
      else
        ship_code = ''
      end
      order_arr = [
        order.order_number.to_s, '', ship_code, pretty_date,
        bill.last_name, bill.first_name, bill.address, bill.city,
        bill.state, bill.zip, bill.country.name, bill.telephone,
        ship.last_name, ship.first_name, ship.address, ship.city,
        ship.state, ship.zip, ship.country.name, ship.telephone 
      ]
      item_arr = []
      # Generate spaces for items up to 16 deep
      0.upto(15) do |i|
        item = order.order_line_items[i]
        if !item.nil? && !item.product.nil?  then
          item_arr << item.product.code
          item_arr << item.quantity.to_s
        else
          item_arr << ''
          item_arr << ''
        end
      end
      order_arr.concat(item_arr)
      orders_list_arr << order_arr
    end
    assert_equal csv_array[1..2], orders_list_arr
  end

  
  # Test if a xml file with a list of orders will be generated.
  # TODO: Get rid of the reference to fedex code. 
  def test_get_xml_for_orders
    # We don't have more than one order to test now.
    an_order = orders(:santa_next_christmas_order)
    
    # Create a new order, with a blank shipping type, just to cover a comparison in the method.
    another_order_line_item = OrderLineItem.for_product(items(:small_stuff))

    another_order = Order.new
    
    another_order.order_line_items << another_order_line_item
    another_order.tax = 0.0
    another_order.product_cost = 1.25
    another_order.created_on = 1.day.ago
    another_order.shipping_address = order_addresses(:uncle_scrooge_address)
    another_order.order_user = order_users(:uncle_scrooge)
    another_order.billing_address = order_addresses(:uncle_scrooge_address)
    another_order.shipped_on = "" 
    another_order.promotion_id = 0
    another_order.notes = '<p>Order completed.<br/><span class="info">[04-04-08 05:18 PM]</span></p>'
    another_order.referer = "" 
    another_order.shipping_cost = 30.0
    another_order.order_number = Order.generate_order_number
    another_order.order_account = order_accounts(:uncle_scrooge_account)
    another_order.auth_transaction_id = "" 
    another_order.order_status_code = order_status_codes(:cart)

    assert another_order.save
    
    # Test the XML.
    require 'rexml/document'
    
    xml = REXML::Document.new(Order.get_xml_for_orders([an_order, another_order]))
    assert xml.root.name, "orders"

    # TODO: For some elements the name don't correspond with the content.
    # This can be tested a little more.
  end

  
  # Test if the line item that represents a promotion is returned if present.
  # FIXME: This method doesn't find the promotion line item if the promotion has an associated item (get 1 free promotions).
  def test_return_promotion_line_item
    a_promotion = promotions(:percent_rebate)
    an_order_line_item = OrderLineItem.for_product(items(:small_stuff))
 
    an_order = Order.new
    
    an_order.order_line_items << an_order_line_item
    an_order.tax = 0.0
    an_order.created_on = 1.day.ago
    an_order.shipping_address = order_addresses(:uncle_scrooge_address)
    an_order.order_user = order_users(:uncle_scrooge)
    an_order.billing_address = order_addresses(:uncle_scrooge_address)
    an_order.shipped_on = "" 
    an_order.order_shipping_type = order_shipping_types(:ups_xp_critical)
    an_order.notes = '<p>Order completed.<br/><span class="info">[04-04-08 05:18 PM]</span></p>'
    an_order.referer = "" 
    an_order.shipping_cost = 30.0
    an_order.order_number = Order.generate_order_number
    an_order.order_account = order_accounts(:uncle_scrooge_account)
    an_order.auth_transaction_id = "" 
    an_order.order_status_code = order_status_codes(:ordered_paid_to_ship)
    
    an_order.promotion_code = a_promotion.code
    an_order.set_promo_code

    assert an_order.save
    
    assert_equal an_order.promotion_line_item.name, a_promotion.description
  end
  
  
  # Test if the current status of an order will be shown with success.
  def test_get_order_status
    an_order = orders(:santa_next_christmas_order)
    assert_equal an_order.status, order_status_codes(:ordered_paid_to_ship).name
  end
  
  
  # Test if we can refer to order_line_items simply using items.
  def test_return_items
    # TODO: Why not use an alias here?
    an_order = orders(:santa_next_christmas_order)
    assert_equal an_order.order_line_items, an_order.items
  end
  
  
  # Test if we can get the total order value.
  def test_get_total_order_value
    # TODO: Why log this?
    an_order = orders(:santa_next_christmas_order)
    assert_equal an_order.total, an_order.line_items_total + an_order.shipping_cost + an_order.tax_cost
  end
  
  
  # Test if we can get the tax total cost for the order.
  def test_get_total_tax_cost
    an_order = orders(:santa_next_christmas_order)
    assert_equal an_order.tax_cost, (an_order.line_items_total) * (an_order.tax/100)
  end
  
  
  # Test if we can refer to the billing address name.
  def test_name
    order = orders(:santa_next_christmas_order)
    assert_equal order.name, "#{order.billing_address.first_name} #{order.billing_address.last_name}"
    order.billing_address.destroy
    order.reload
    assert_equal '', order.name
  end
  
  # Test if we can refer to order_account simply using account.
  def test_return_account
    # TODO: Why not use an alias here?
    an_order = orders(:santa_next_christmas_order)
    assert_equal an_order.order_account, an_order.account
  end
  
  
  # Test if a hash containing item ids and quantities can be used to fill the list.
  # TODO: Doing that the name of the line item isn't set.
  # TODO: Get rid of this method if it will not be used.
  def test_build_line_items_from_hash
    # Create a new order and put just one line item.
    an_order_line_item = OrderLineItem.for_product(items(:small_stuff))

    an_order = Order.new
    
    an_order.order_line_items << an_order_line_item
    an_order.tax = 0.0
    an_order.created_on = 1.day.ago
    an_order.shipping_address = order_addresses(:uncle_scrooge_address)
    an_order.customer = order_users(:uncle_scrooge)
    an_order.billing_address = order_addresses(:uncle_scrooge_address)
    an_order.shipped_on = "" 
    an_order.order_shipping_type = order_shipping_types(:ups_xp_critical)
    an_order.promotion_id = 0
    an_order.notes = '<p>Order completed.<br/><span class="info">[04-04-08 05:18 PM]</span></p>'
    an_order.referer = "" 
    an_order.shipping_cost = 30.0
    an_order.order_number = Order.generate_order_number
    an_order.order_account = order_accounts(:uncle_scrooge_account)
    an_order.auth_transaction_id = "" 
    an_order.order_status_code = order_status_codes(:ordered_paid_to_ship)

    assert an_order.save
    
    # Now try to feed it with others.
    an_order.line_items = {
      items(:red_lightsaber).id => {'quantity' => 2},
      items(:towel).id => {'quantity' => 1},
      items(:blue_lightsaber).id => {'quantity' => ""}
    }
    
    assert_equal an_order.order_line_items.size, 2
  end

  
  # Test an order to see if it will correctly say if has a valid transaction id.
  def test_show_if_contains_valid_transaction_id
    an_order = orders(:santa_next_christmas_order)
    assert_equal an_order.contains_valid_transaction_id?, false
    
    assert an_order.update_attributes(:auth_transaction_id => 123)
    assert_equal an_order.contains_valid_transaction_id?, true
  end
  
  
  # Test an order to see if it will correctly say if has an specific line item.
  # TODO: The comment about how to use this method and how it should really be used are different.
  # TODO: Get rid of this method if it will not be used.
  def test_show_if_has_line_item
    an_order = orders(:santa_next_christmas_order)
    assert_equal an_order.has_line_item?(an_order.order_line_items.find_by_name(items(:towel).name).id), true

    # Create a new order and put just one line item.
    new_order_line_item = OrderLineItem.for_product(items(:small_stuff))
    new_order = Order.new
    new_order.order_line_items << new_order_line_item
    assert new_order.save
    
    # Search for an existent line item of ANOTHER order.
    assert_equal an_order.has_line_item?(new_order.order_line_items.find_by_name(items(:small_stuff).name).id), false
  end
  
  
  # Test an order to see if it will correctly say how many products it have in a line item.
  # TODO: The comment about how to use this method and how it is really being used are different.
  # Why use a line item id, it is meaningless. Probably the current use and the method code are wrong.
  def test_get_line_item_quantity
    an_order = orders(:santa_next_christmas_order)
    assert_equal an_order.get_line_item_quantity(an_order.order_line_items.find_by_name(items(:towel).name).id), order_line_items(:santa_next_christmas_order_item_6).quantity

    # Create a new order and put just one line item.
    new_order_line_item = OrderLineItem.for_product(items(:small_stuff))
    new_order = Order.new
    new_order.order_line_items << new_order_line_item
    assert new_order.save
    
    # Search for an existent line item of ANOTHER order.
    assert_equal an_order.get_line_item_quantity(new_order.order_line_items.find_by_name(items(:small_stuff).name).id), 0
  end


  # Test an order to see if it will correctly show a specific line item total.
  # TODO: The comment about how to use this method and how it is really being used are different.
  # Why use a line item id, it is meaningless. Probably the current use and the method code are wrong.
  def test_get_line_item_total
    an_order = orders(:santa_next_christmas_order)
    assert_equal an_order.get_line_item_total(an_order.order_line_items.find_by_name(items(:towel).name).id), order_line_items(:santa_next_christmas_order_item_6).total

    # Create a new order and put just one line item.
    new_order_line_item = OrderLineItem.for_product(items(:small_stuff))
    new_order = Order.new
    new_order.order_line_items << new_order_line_item
    assert new_order.save
    
    # Search for an existent line item of ANOTHER order.
    assert_equal an_order.get_line_item_total(new_order.order_line_items.find_by_name(items(:small_stuff).name).id), 0
  end


  # Test an order to see if it will correctly show all line items total.
  def test_get_all_line_items_total
    an_order = orders(:santa_next_christmas_order)
    assert_equal an_order.line_items_total, an_order.order_line_items.collect{ |p| p.unit_price * p.quantity }.sum
  end


  def test_new_notes_update_attr
    # Notes need to be NIL in order to test an edge case error.
    @santa_order.update_attribute(:notes, nil)
    # ^^ DONT REMOVE THIS
    @santa_order.update_attributes({
      :new_notes => 'Hello world.'
    })
    @santa_order.reload
    assert_not_nil @santa_order.notes
    assert @santa_order.notes.include?("<span class=\"info\">")
  end  

  # Test an order to see if the correct total weight will be returned.
  def test_return_total_weight
    an_order = orders(:santa_next_christmas_order)
    calculated_weight = 0
    an_order.order_line_items.each do |item|
      calculated_weight += item.quantity * item.product.weight
    end
    assert_equal an_order.weight, calculated_weight
  end
  
  
  # Test an order to see if a flat shipping price will be returned.
  def test_get_flat_shipping_price
    # TODO: Should this method really be here?
    an_order = Order.new
    assert_equal an_order.get_flat_shipping_price, Preference.find_by_name('store_handling_fee').value.to_f
  end
  
  
  # Test an order to see if the correct shipping prices will be returned.
  def test_get_shipping_prices
    # Test a national shipping order.
    an_order = orders(:santa_next_christmas_order)
    assert_same_elements an_order.get_shipping_prices, OrderShippingType.get_domestic
    
    # Turn it into an international one and test.
    an_address = order_addresses(:santa_address)
    an_address.country = countries(:GB)
    an_address.save
    an_order.reload
    assert_same_elements an_order.get_shipping_prices, OrderShippingType.get_foreign
    
    # Now we say that we are in that same other country.
    prefs = {
      "store_home_country" => countries(:GB).id
    }
    assert Preference.save_settings(prefs)
    
    # And that same shipment should be national now.
    assert_same_elements an_order.get_shipping_prices, OrderShippingType.get_domestic
  end
  
  
  # Run a payment transaction of the type defined in preferences.
  def test_run_transaction
    # Get any order.
    an_order = orders(:santa_next_christmas_order)
    
    # Now we say that we will use authorize. Mock the method and test it.
    assert Preference.save_settings({ "cc_processor" => "Authorize.net" })
    Order.any_instance.expects(:run_transaction_authorize).once.returns('executed_authorize')
    assert_equal an_order.run_transaction, "executed_authorize"

    # Now we say that we will use paypal ipn. Mock the method and test it.
    assert Preference.save_settings({ "cc_processor" => "PayPal IPN" })
    Order.any_instance.expects(:run_transaction_paypal_ipn).once.returns('executed_paypal_ipn')
    assert_equal an_order.run_transaction, "executed_paypal_ipn"

    # Now we say that we will use a non existent processor.
    assert Preference.save_settings({ "cc_processor" => "Nonexistent" })
    assert_throws(:"The currently set preference for cc_processor is not recognized. You might want to add it to the code..."){an_order.run_transaction}
  end


  # Test an order to see if the cc processor will be returned.
  def test_get_cc_processor
    # TODO: Should this method really be here?
    assert_equal Order.get_cc_processor, Preference.find_by_name('cc_processor').value.to_s
  end


  # Test an order to see if the cc login will be returned.
  def test_get_cc_login
    # TODO: Should this method really be here?
    assert_equal Order.get_cc_login, Preference.find_by_name('cc_login').value.to_s
  end


  # Run an Authorize.net payment transaction with success.
  def test_run_transaction_authorize_with_success
    # Setup the mailer.
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    initial_mbox_length = ActionMailer::Base.deliveries.length

    # Get any order.
    an_order = orders(:santa_next_christmas_order)
    
    # Create a standard success response. Parameters: success, message, params = {}, options = {}
    a_positive_response = ActiveMerchant::Billing::Response.new(
      true,
      "(TESTMODE) This transaction has been approved",
      {
        :response_reason_text => "(TESTMODE) This transaction has been approved.",
        :response_reason_code => "1",
        :response_code => "1",
        :avs_message => "Address verification not applicable for this transaction",
        :transaction_id => "0",
        :avs_result_code => "P",
        :card_code => nil
     }, {
        :test => true,
        :authorization => "0",
        :fraud_review => false
      }
    )
    
    # Stub the purchase method to not call home (using commit) and return a standard success response.
    ActiveMerchant::Billing::AuthorizeNetGateway.any_instance.stubs(:purchase).returns(a_positive_response)

    # Assert that with a success response the method will return true.
    assert_equal an_order.run_transaction_authorize, true

    # We should have received a mail about that.
    assert_equal ActionMailer::Base.deliveries.length, initial_mbox_length + 1
 
    
    # Stub the deliver_receipt method to raise an exception.
    Order.any_instance.stubs(:deliver_receipt).raises('An error!')
    
    # Run the transaction again.
    an_order.run_transaction_authorize
    # We don't need to assert the raise because it will be caugh in run_transaction_authorize.

    # We should NOT have received a mail about that.
    assert_equal ActionMailer::Base.deliveries.length, initial_mbox_length + 1
  end


  # Run an Authorize.net payment transaction with failure.
  def test_run_transaction_authorize_with_failure
    # Setup the mailer.
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    initial_mbox_length = ActionMailer::Base.deliveries.length

    # Get any order.
    an_order = orders(:santa_next_christmas_order)
    
    # Create a standard failure response when cc number is wrong. Parameters: success, message, params = {}, options = {}
    a_negative_response = ActiveMerchant::Billing::Response.new(
      false,
      "(TESTMODE) The credit card number is invalid",
      {
        :response_reason_text => "(TESTMODE) The credit card number is invalid.",
        :response_reason_code => "6",
        :response_code => "3",
        :avs_message => "Address verification not applicable for this transaction",
        :transaction_id => "0",
        :avs_result_code => "P",
        :card_code => nil
     }, {
        :test => true,
        :authorization => "0",
        :fraud_review => false
      }
    )
    
    # Stub the purchase method to not call home (using commit) and return a standard failure response.
    ActiveMerchant::Billing::AuthorizeNetGateway.any_instance.stubs(:purchase).returns(a_negative_response)

    # Assert that with a failure response the method will return the response message.
    assert_equal an_order.run_transaction_authorize, a_negative_response.message

    # We should have received a mail about that.
    assert_equal ActionMailer::Base.deliveries.length, initial_mbox_length + 1
 
    
    # Stub the deliver_failed method to raise an exception.
    Order.any_instance.stubs(:deliver_failed).raises('An error!')
    
    # Run the transaction again.
    an_order.run_transaction_authorize
    # We don't need to assert the raise because it will be caugh in run_transaction_authorize.

    # We should NOT have received a mail about that.
    assert_equal ActionMailer::Base.deliveries.length, initial_mbox_length + 1
  end


  # Run an Paypal IPN payment transaction.
  # TODO: This method don't run a transaction, it only change the status code and add a note.
  # TODO: Could't configure Paypal IPN to work.
  def test_run_transaction_paypal_ipn
    # Create a new order, incomplete, just to work with.
    an_order_line_item = OrderLineItem.for_product(items(:small_stuff))

    an_order = Order.new
    
    an_order.order_line_items << an_order_line_item
    an_order.tax = 0.0
    an_order.product_cost = 1.25
    an_order.created_on = 1.day.ago
    an_order.shipping_address = order_addresses(:uncle_scrooge_address)
    an_order.customer = order_users(:uncle_scrooge)
    an_order.billing_address = order_addresses(:uncle_scrooge_address)
    an_order.shipped_on = "" 
    an_order.order_shipping_type = order_shipping_types(:ups_xp_critical)
    an_order.promotion_id = 0
    an_order.notes = '<p>Order completed.<br/><span class="info">[04-04-08 05:18 PM]</span></p>'
    an_order.referer = "" 
    an_order.shipping_cost = 30.0
    an_order.order_number = Order.generate_order_number
    an_order.order_account = order_accounts(:uncle_scrooge_account)
    an_order.auth_transaction_id = "" 
    an_order.order_status_code = order_status_codes(:cart)

    assert an_order.save
    
    notes_before = an_order.notes.dup

    # Running it should return the new status code.
    assert_equal an_order.run_transaction_paypal_ipn, order_status_codes(:on_hold_awaiting_payment).id
    # A new note should be added.
    notes_after = an_order.notes
    assert_not_equal notes_before, notes_after
  end


  # Test the cleaning of a successful order.
  def test_cleanup_successful
    # Create a new order.
    an_order_line_item = OrderLineItem.for_product(items(:small_stuff))

    an_order = Order.new
    
    an_order.order_line_items << an_order_line_item
    an_order.tax = 0.0
    an_order.product_cost = 1.25
    an_order.created_on = 1.day.ago
    an_order.shipping_address = order_addresses(:uncle_scrooge_address)
    an_order.customer = order_users(:uncle_scrooge)
    an_order.billing_address = order_addresses(:uncle_scrooge_address)
    an_order.shipped_on = "" 
    an_order.order_shipping_type = order_shipping_types(:ups_xp_critical)
    an_order.promotion_id = 0
    an_order.notes = ''
    an_order.referer = "" 
    an_order.shipping_cost = 30.0
    an_order.order_number = Order.generate_order_number
    an_order.order_account = order_accounts(:uncle_scrooge_account)
    an_order.auth_transaction_id = "" 
    an_order.order_status_code = order_status_codes(:cart)

    assert an_order.save
    assert_equal an_order.order_status_code, order_status_codes(:cart)
    
    # Make sure inventory control is enabled.
    assert Preference.find_by_name('store_use_inventory_control').is_true?
    # Make sure cc number obfuscation is enabled.
    assert Preference.find_by_name('cc_clear_after_order').is_true?
    
    initial_quantity = an_order_line_item.item.quantity
    notes_before = an_order.notes.clone
    
    an_order.cleanup_successful
    
    an_order_line_item.item.reload
    
    # Quantity should be updated.
    assert_equal an_order_line_item.item.quantity, (initial_quantity - an_order_line_item.quantity)
    # Status code should be updated.
    an_order.reload
    assert_equal an_order.order_status_code, order_status_codes(:ordered_paid_to_ship)
    
    # CC number should be obfuscated.
    number_len = an_order.account.cc_number.length
    new_cc_number = an_order.account.cc_number[number_len - 4, number_len].rjust(number_len, 'X')
    assert_equal an_order.account.cc_number, new_cc_number
    
    # A new note should be added.
    notes_after = an_order.notes
    assert_not_equal notes_before, notes_after
  end


  # Test the cleaning of a failed order.
  def test_cleanup_failed
    # Create a new order.
    an_order_line_item = OrderLineItem.for_product(items(:small_stuff))

    an_order = Order.new
    
    an_order.order_line_items << an_order_line_item
    an_order.tax = 0.0
    an_order.product_cost = 1.25
    an_order.created_on = 1.day.ago
    an_order.shipping_address = order_addresses(:uncle_scrooge_address)
    an_order.customer = order_users(:uncle_scrooge)
    an_order.billing_address = order_addresses(:uncle_scrooge_address)
    an_order.shipped_on = "" 
    an_order.order_shipping_type = order_shipping_types(:ups_xp_critical)
    an_order.promotion_id = 0
    an_order.notes = '<p>Order completed.<br/><span class="info">[04-04-08 05:18 PM]</span></p>'
    an_order.referer = "" 
    an_order.shipping_cost = 30.0
    an_order.order_number = Order.generate_order_number
    an_order.order_account = order_accounts(:uncle_scrooge_account)
    an_order.auth_transaction_id = "" 
    an_order.order_status_code = order_status_codes(:cart)

    assert an_order.save
    
    notes_before = an_order.notes.dup

    an_order.cleanup_failed("A message!")
    
    # Status code should be updated.
    assert_equal an_order.order_status_code, order_status_codes(:on_hold_payment_failed)
    # A new note should be added.
    notes_after = an_order.notes
    assert_not_equal notes_before, notes_after
  end


  # Test the deliver of the e-mail message in case of success.
  def test_deliver_receipt
    # Setup the mailer.
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    initial_mbox_length = ActionMailer::Base.deliveries.length

    # Get any order.
    an_order = orders(:santa_next_christmas_order)
    an_order.deliver_receipt    

    # We should have received a mail about that.
    assert_equal ActionMailer::Base.deliveries.length, initial_mbox_length + 1
    
    receipt_content = ContentNode.find(:first, :conditions => ["name = ?", 'OrderReceipt'])
    
    # Create a block that guarantees that the content node name will be recovered.
    begin
      assert receipt_content.update_attributes(:name => 'order_receipt')

      an_order.deliver_receipt    

      # We should NOT have received a mail about that.
      assert_equal ActionMailer::Base.deliveries.length, initial_mbox_length + 1
    ensure
      # Put the name back.
      assert receipt_content.update_attributes(:name => 'OrderReceipt')
    end
  end


  # Test the deliver of the e-mail message in case of error.
  def test_deliver_failed
    # Setup the mailer.
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    initial_mbox_length = ActionMailer::Base.deliveries.length

    # Get any order.
    an_order = orders(:santa_next_christmas_order)
    an_order.deliver_failed    

    # We should have received a mail about that.
    assert_equal ActionMailer::Base.deliveries.length, initial_mbox_length + 1
  end
  

  # Test the order have a promotion applied.
  def test_say_if_is_discounted
    a_promotion = promotions(:percent_rebate)
    an_order_line_item = OrderLineItem.for_product(items(:small_stuff))
 
    an_order = Order.new
    
    an_order.order_line_items << an_order_line_item
    an_order.tax = 0.0
    an_order.created_on = 1.day.ago
    an_order.shipping_address = order_addresses(:uncle_scrooge_address)
    an_order.customer = order_users(:uncle_scrooge)
    an_order.billing_address = order_addresses(:uncle_scrooge_address)
    an_order.shipped_on = "" 
    an_order.order_shipping_type = order_shipping_types(:ups_xp_critical)
    an_order.notes = '<p>Order completed.<br/><span class="info">[04-04-08 05:18 PM]</span></p>'
    an_order.referer = "" 
    an_order.shipping_cost = 30.0
    an_order.order_number = Order.generate_order_number
    an_order.order_account = order_accounts(:uncle_scrooge_account)
    an_order.auth_transaction_id = "" 
    an_order.order_status_code = order_status_codes(:ordered_paid_to_ship)
    
    assert !an_order.is_discounted?
    an_order.promotion_code = a_promotion.code
    an_order.set_promo_code
    assert an_order.is_discounted?
  end
  
  
  # Test if the contents of the IPN posted back are in conformity with what was sent, here the IPN is validated.
  def test_say_if_matches_ipn
    # Create a new order.
    an_order_line_item = OrderLineItem.for_product(items(:small_stuff))
    another_order_line_item = OrderLineItem.for_product(items(:towel))

    an_order = Order.new
    
    an_order.order_line_items << an_order_line_item
    an_order.order_line_items << another_order_line_item
    an_order.tax = 0.0
    an_order.created_on = 1.day.ago
    an_order.shipping_address = order_addresses(:uncle_scrooge_address)
    an_order.customer = order_users(:uncle_scrooge)
    an_order.billing_address = order_addresses(:uncle_scrooge_address)
    an_order.shipped_on = "" 
    an_order.order_shipping_type = order_shipping_types(:ups_ground)
    an_order.promotion_id = 0
    an_order.notes = '<p>Order completed.<br/><span class="info">[04-04-08 05:18 PM]</span></p>'
    an_order.referer = "" 
    an_order.shipping_cost = 11.0
    an_order.order_number = Order.generate_order_number
    an_order.order_account = order_accounts(:uncle_scrooge_account)
    an_order.auth_transaction_id = "" 
    an_order.order_status_code = order_status_codes(:cart)

    assert an_order.save
    
    # TODO: Take a look closely how these params are filled in the paypal guides.
    # Create a fake hash to be used as params and to generate the query string.
    fake_params = {
      :address_city => "San Jose",
      :address_country => "United States",
      :address_country_code => "US",
      :address_name => "Test User",
      :address_state => "CA",
      :address_status => "confirmed",
      :address_street => "1 Main St",
      :address_zip => "95131",
      :business => "seller@my.own.store",
      :charset => "windows-1252",
      :custom => "",
      :first_name => "Test",
      :last_name => "User",
      :invoice => an_order.order_number,
      
      :item_name1 => an_order.order_line_items[0].name,
      :item_name2 => an_order.order_line_items[1].name,
      :item_number1 => "",
      :item_number2 => "",
      :mc_currency => "USD",
      :mc_fee => "0.93",
      :mc_gross => an_order.line_items_total + an_order.shipping_cost,
      # Why the shipping cost is here?
      :mc_gross_1 => an_order.order_line_items[0].total + an_order.shipping_cost,
      :mc_gross_2 => an_order.order_line_items[1].total,
      :mc_handling => "0.00",
      :mc_handling1 => "0.00",
      :mc_handling2 => "0.00",
      :mc_shipping => an_order.shipping_cost,
      :mc_shipping1 => an_order.shipping_cost,
      :mc_shipping2 => "0.00",
      :notify_version => "2.4",
      :num_cart_items => an_order.order_line_items.length,
      :payer_email => "buyer@my.own.store",
      :payer_id => "3GQ2THTEB86ES",
      :payer_status => "verified",
      :payment_date => "08:41:36 May 28, 2008 PDT",
      :payment_fee => "0.93",
      :payment_gross => "21.75",
      :payment_status => "Completed",
      :payment_type => "instant",
      :quantity1 => an_order.order_line_items[0].quantity,
      :quantity2 => an_order.order_line_items[1].quantity,
      :receiver_email => "seller@my.own.store",
      :receiver_id => "TFLJN8N28W6VW",
      :residence_country => "US",
      :tax => "0.00",
      :tax1 => "0.00",
      :tax2 => "0.00",
      :test_ipn => "1",
      :txn_id => "53B76609FE637874A",
      :txn_type => "cart",
      :verify_sign => "AKYASk7fkoMqSjT.TB-8hzZ9riLTAVyg5ho1FZd9XrCkuXZCpp-Q6uEY",
      :memo => "A message."
    }
   
    # Configure the Paypal store login.
    assert Preference.save_settings({ "cc_login" => fake_params[:business] })

    # Create the parameters required by the matches_ipn method.
    notification = ActiveMerchant::Billing::Integrations::Paypal::Notification.new(fake_params.to_query)
    complete_params = fake_params.merge({ :action => "ipn", :controller => "paypal" })
    
    # Test a call that should succeed.
    assert Order.matches_ipn(notification, an_order, complete_params)

    # Change the parameter mc_gross and it should fail.
    wrong_notification = ActiveMerchant::Billing::Integrations::Paypal::Notification.new(fake_params.merge({ :mc_gross => "2.00" }).to_query)
    assert !Order.matches_ipn(wrong_notification, an_order, complete_params), "It should have failed because :mc_gross."

    # Change the parameter business and it should fail.
    assert !Order.matches_ipn(notification, an_order, complete_params.merge({ :business => "somebody@else" })), "It should have failed because :business."

    # It should fail if finds another order with the same txn_id.
    another_order = orders(:santa_next_christmas_order)
    another_order.auth_transaction_id = fake_params[:txn_id]
    another_order.save
    assert !Order.matches_ipn(notification, an_order, complete_params), "It should have failed because another order already have this txn_id."
 end
  

  # Test the method that mark the order with a success status, if everything is fine with the IPN received.
  # TODO: Should this method really be here?
  def test_pass_ipn
    # Setup the mailer.
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    initial_mbox_length = ActionMailer::Base.deliveries.length

    # Get any order.
    an_order = orders(:santa_next_christmas_order)

    notes_before = an_order.notes.dup
    
    # Set a fake fixed transaction id.
    txn_id = "3HY99478SV091020H"
    
    # Pass the order and the fake txn_id.
    Order.pass_ipn(an_order, txn_id)
    
    # TODO: The status code is being redefined in this method without need.
    # It will be redefined again in order.cleanup_successful.

    # Assert the transaction id was saved.
    assert_equal an_order.auth_transaction_id, txn_id

    # A new note should be added.
    notes_after = an_order.notes
    assert_not_equal notes_before, notes_after
    
    # We should have received a mail about that.
    assert_equal ActionMailer::Base.deliveries.length, initial_mbox_length + 1
    
    
    # Stub the deliver_receipt method to raise an exception.
    Order.any_instance.stubs(:deliver_receipt).raises('An error!')
    
    # Pass the order and the fake txn_id.
    Order.pass_ipn(an_order, txn_id)
    # We don't need to assert the raise because it will be caugh in pass_ipn.

    # We should NOT have received a mail about that.
    assert_equal ActionMailer::Base.deliveries.length, initial_mbox_length + 1
  end
  

  # Test the method that mark the order with a fail status, if something is wrong with the IPN received.
  # TODO: Should this method really be here?
  def test_fail_ipn
    # Setup the mailer.
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    initial_mbox_length = ActionMailer::Base.deliveries.length

    # Get any order.
    an_order = orders(:santa_next_christmas_order)

    notes_before = an_order.notes.dup
    
    # Pass the order.
    Order.fail_ipn(an_order)
    
    # TODO: The status code is being redefined in this method without need.
    # It will be redefined again in order.cleanup_failed.

    # A new note should be added.
    notes_after = an_order.notes
    assert_not_equal notes_before, notes_after
    
    # We should have received a mail about that.
    assert_equal ActionMailer::Base.deliveries.length, initial_mbox_length + 1

  
    # Stub the deliver_receipt method to raise an exception.
    Order.any_instance.stubs(:deliver_failed).raises('An error!')
    
    # Pass the order.
    Order.fail_ipn(an_order)
    # We don't need to assert the raise because it will be caugh in fail_ipn.

    # We should NOT have received a mail about that.
    assert_equal ActionMailer::Base.deliveries.length, initial_mbox_length + 1
  end


  #############################################################################
  # CART COMPATIBILITY METHODS
  #
  # These tests are to ensure compatibility of Order with the Cart object
  # which has been removed.
  #############################################################################
  
  
  def test_empty
    order = orders(:santa_next_christmas_order)
    assert !order.empty?
    assert order.order_line_items.size > 0
    order.empty!
    assert order.empty?
    assert_equal order.order_line_items.size, 0
  end
  
  # When created the cart should be empty.
  def test_when_created_be_empty
    a_cart = Order.new
    
    assert_equal a_cart.items.size, 0
    assert_equal a_cart.tax, 0.0
    assert_equal a_cart.total, 0.0
    assert_equal a_cart.shipping_cost, 0.0
  end


  # Test if a product can be added to the cart.
  def test_add_product
    a_cart = Order.new
    a_cart.add_product(items(:red_lightsaber), 1)
    a_cart.add_product(items(:red_lightsaber), 3)
    assert_equal 1, a_cart.items.length, "Cart added multiple order line items for the same product. #{a_cart.items.inspect}"
    assert a_cart.save
    a_cart.reload()
    assert_equal 1, a_cart.items.length
    assert_equal 4, a_cart.items[0].quantity
  end
  
  # Test if a add_product properly handles negative quantities
  def test_add_product_with_negative_quantity
    a_cart = Order.new
    a_cart.add_product(items(:blue_lightsaber), 2)
    a_cart.add_product(items(:blue_lightsaber), -1)
    a_cart.reload
    # Calling add_product with a negative quantity should remove that many units
    assert_equal 1, a_cart.items[0].quantity
    a_cart.add_product(items(:blue_lightsaber), -3)    
#    a_cart.reload
    assert a_cart.empty?
  end

  # Test if a product can be removed from the cart.
  def test_remove_product
    a_cart = Order.new
    a_cart.add_product(items(:red_lightsaber), 2)
    a_cart.add_product(items(:blue_lightsaber), 2)
    assert_equal a_cart.items.length, 2
    # When not specified a quantity all units from the product will be removed.
    a_cart.remove_product(items(:blue_lightsaber))
    assert_equal a_cart.items.length, 1
    # When specified a quantity, just these units from the product will be removed.
    a_cart.remove_product(items(:red_lightsaber), 1)
    assert_equal a_cart.items.length, 1
    # It should not be empty.
    assert !a_cart.empty?
    # Now it should be empty.
    a_cart.remove_product(items(:red_lightsaber), 1)
    assert a_cart.empty?
  end


  # Test if what is in the cart is really available in the inventory.
  def test_check_inventory
    # Create a cart and add some products.
    a_cart = Order.new
    a_cart.add_product(items(:red_lightsaber), 2)
    a_cart.add_product(items(:blue_lightsaber), 4)
    assert_equal a_cart.items.length, 2
    
    an_out_of_stock_product = items(:red_lightsaber)
    assert an_out_of_stock_product.update_attributes(:quantity => 1)
    
    # Assert that the product that was out of stock was removed.
    removed_products = a_cart.check_inventory
    assert_equal removed_products, [an_out_of_stock_product.name]

    # Should last the right quantity of the rest.
    assert_equal a_cart.items.length, 1
  end
  
  def test_check_inventory_with_promotion
    # Create cart, add item & promotion
    a_cart = Order.new
    a_cart.add_product(items(:red_lightsaber), 2)
    a_cart.promotion_code = "FIXED_REBATE"
    assert a_cart.save
    assert_nothing_raised do
      a_cart.check_inventory
    end
  end
  
  
  # Test if will return the total price of products in the cart.
  def test_return_total_price
    # Create a cart and add some products.
    a_cart = Order.new
    a_cart.add_product(items(:red_lightsaber), 2)
    a_cart.add_product(items(:blue_lightsaber), 4)
    assert_equal a_cart.items.length, 2

    total = 0.0
    for item in a_cart.items
      total += (item.quantity * item.unit_price)
    end

    assert_equal total, a_cart.total
  end

  # Test if will return the tax cost for the total in the cart.
  def test_return_tax_cost
    # Create a cart and add some products.
    a_cart = Order.new
    a_cart.add_product(items(:red_lightsaber), 2)
    a_cart.add_product(items(:blue_lightsaber), 4)
    
    # By default tax is zero.
    assert_equal a_cart.tax_cost, a_cart.total * a_cart.tax
  end

  # Test if will return the line items total.
  def test_return_line_items_total
    # Create a cart and add some products.
    a_cart = Order.new
    a_cart.add_product(items(:red_lightsaber), 2)
    a_cart.add_product(items(:blue_lightsaber), 4)
    
    assert_equal a_cart.line_items_total, a_cart.total
  end

  def test_has_downloads
    assert_equal 1, @santa_order.downloads.count
    assert_equal items(:towel).downloads, @santa_order.downloads
  end

end
