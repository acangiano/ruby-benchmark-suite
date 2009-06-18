class Country < ActiveRecord::Base
  has_many :order_addresses
  
  # Returns count of number of orders for a particular country
  #
  def number_of_orders
    sql  = "SELECT COUNT(*) as count "
    sql << "FROM orders "
    sql << "INNER JOIN order_addresses ON ( "
    sql << "  order_addresses.country_id = #{self.id} AND order_addresses.id = orders.shipping_address_id "
    sql << ");"
    Order.count_by_sql(sql)
  end
end
