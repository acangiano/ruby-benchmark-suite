class Product < Item
  # Conditions that the product is in stock, or available 
  # and just out of stock.
  CONDITIONS_AVAILABLE = %Q/
      CURRENT_DATE() >= DATE(items.date_available)
      AND items.is_discontinued = 0
      OR (items.is_discontinued = 1 AND (items.quantity > 0 OR items.variation_quantity > 0))
  /

  has_many :product_images, :dependent => :destroy
  has_many :images, 
    :through => :product_images, :order => "-product_images.rank DESC",
    :dependent => :destroy
  has_many :product_downloads, :dependent => :destroy
  has_many :downloads, 
    :through => :product_downloads, :order => "-product_downloads.rank DESC",
    :dependent => :destroy
  has_many :variations, 
    :dependent => :destroy, :order => 'name ASC'
  
  # Join with related items...
  has_and_belongs_to_many :related_products,
    :class_name => 'Product',
    :join_table => 'related_products',
    :association_foreign_key => 'related_id',
    :foreign_key => 'product_id',
    :after_add => :add_return_relation,
    :after_remove => :remove_return_relation
    
  def add_return_relation(relative)
    relative.related_products << self unless relative.related_products.include?(self)
  end
  def remove_return_relation(relative)
    sql  = "DELETE FROM related_products "
    sql << "WHERE product_id = #{relative.id} AND related_id = #{self.id}"
    ActiveRecord::Base.connection.execute(sql)
  end
  
	has_and_belongs_to_many :tags

  #############################################################################
  # CALLBACKS
  #############################################################################


	#############################################################################
	# CLASS METHODS
	#############################################################################

	# Admin search for products
	# Uses product name, code, or description
	def self.search(search_term, count=false, limit_sql=nil)
	  if (count == true) then
	    sql = "SELECT COUNT(*) "
	  else
	    sql = "SELECT DISTINCT * "
		end
		sql << "FROM items "
		sql << "WHERE ("
		sql << "  name LIKE ? "
		sql << "  OR items.description LIKE ? "
		sql << "  OR items.code LIKE ? "
		sql << ") AND items.type = 'Product' "
		sql << "ORDER BY date_available DESC "
		sql << "LIMIT #{limit_sql}" if limit_sql
		arg_arr = [sql, "%#{search_term}%", "%#{search_term}%", "%#{search_term}%"]
		if (count == true) then
		  count_by_sql(arg_arr)
	  else
		  find_by_sql(arg_arr)
	  end
	end

	# Finds products by list of tag ids passed in
	#
	# We could JOIN multiple times, but selecting IN grabs us the products
	# and using GROUP BY & COUNT with the number of tag id's given
	# is a faster approach according to freenode #mysql
	def self.find_by_tags(tag_ids, find_available=false, order_by="items.date_available DESC")
		sql =  "SELECT * "
		sql << "FROM items "
		sql << "JOIN products_tags on items.id = products_tags.product_id "
		sql << "WHERE products_tags.tag_id IN (#{tag_ids.join(",")}) "
		sql << "AND #{CONDITIONS_AVAILABLE}" if find_available==true
		sql << "GROUP BY items.id HAVING COUNT(*)=#{tag_ids.length} "
		sql << "ORDER BY #{order_by};"
		find_by_sql(sql)
	end
	
	#############################################################################
	# INSTANCE METHODS
	#############################################################################

  substruct_deprecate :tags= => :tag_ids=

  # This method is DEPRECATED.
  # This method has an equivalent auto-generated but must be here to not
  # generate an infinite looping. It can be simply excluded after some time.
  def tag_ids=(list)
    tags.clear
    for id in list
      tags << Tag.find(id) if !id.empty?
    end
  end

	# Calculated based on variations
	#
	def display_price
	  variations = self.variations.find(:all, :order => "price ASC")
	  if variations.size == 0
	    return self.price
	  else
	    low_price = variations[0].price
	    high_price = variations[variations.size-1].price
      if low_price == high_price
        return low_price
      else
        return [low_price, high_price]
      end
    end
  end

  def display_price?
    display_price.nil?
  end
  
  def quantity
    if self.variations.count == 0
      return self.attributes['quantity']
    else
      return self.variation_quantity
    end
  end
  
  # Is the item active on the site? Is it listed in the store?
  #
  def is_published?
	  !self.is_discontinued? || self.quantity > 0
	end
	
	# Is this product new?
	#
	def is_new?
	  @cached_is_new ||=
	    begin
	      self.date_available >= 2.weeks.ago
      end
  end
  
  # Is this product on sale?
  #
  def is_on_sale?
	  @cached_on_sale ||=
	    begin
	      !self.tags.find_by_name('On Sale').nil?
      end
	end
	
  substruct_deprecate :related_product_ids= => :related_product_suggestion_names=

  # Receive a list o related product suggestion_names (code: name), this is what
  # the autocompletion puts in the boxes, parse and get the code to associate
  # them with the product.
  def related_product_suggestion_names=(list)
    self.related_products.clear
    for name in list do
      p = Product.find_by_code(name.split(':')[0])
      next if !p || p == self
      self.related_products << p
    end
  end

end
