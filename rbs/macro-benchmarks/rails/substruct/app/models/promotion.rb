# Promotions allow discounts to be applied to orders, and
# have the ability to add items to an order as well.
#
#
class Promotion < ActiveRecord::Base
  TYPES = {
    'Dollars' => 0,
    'Percent of total order' => 1,
    'Buy [n] get 1 free' => 2
  }
  # Associations
  has_many :orders
  belongs_to :item
	# Validation
	validates_presence_of :code, :discount_amount, :discount_type, :description
	validates_uniqueness_of :code
	validates_numericality_of :discount_amount
	
	before_save :clean_code
	def clean_code
	  self.code.gsub!(' ', '')
  end
  
  # Makes sure if 'buy n get one free' discount type that
  # a product is selected.
  def validate
    if self.discount_type == 2 && self.item_id.nil?
      errors.add(:item_id, "Please add an item for the 'Buy [n] get 1 free' promotion")
    end
  end
	
	# Generates a 15 character alphanumeric code
	# that we use to track affiliates and promotions.
	#
	def self.generate_code(size=15)
    # characters used to generate affiliate code
    chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890" 
    # create a new record object to satisfy while loop initially
    record = Promotion.new
    # loop through, creating random affiliate codes until
    # we create one that doesn't exist in the db
    while record        
      test_code = "" 
      srand
      size.times do
        pos = rand(chars.length)
        test_code += chars[pos..pos]
      end
      # find any affiliates with this same code string
      # if none are found the while loop exits
      record = find(:first, :conditions => ["code = ?", test_code])
    end
    # return our random code
    return test_code
  end
	
	# Lets us know if any promotions are active.
	#
	def self.any_active?
	  !Promotion.find(
	    :first, 
	    :conditions => "NOW() BETWEEN start AND end"
	  ).nil?
  end
  
  def is_active?
    Time.now.between?(self.start, self.end)
  end
  
	# Setter for product name. Uses suggestion JS and pop-up.
	#
	# We only really use the first item, which is the ID to look
	# up the product.
	def product_name=(name)
	  item = Item.find_by_code(name.split(':')[0])
	  if !item
	    self.item_id = nil
	  else
	    self.item_id = item.id
	  end
	end
	
end