# We made product codes required, so generate a random code for items that
# don't have one.
#
class ProductCodesRequired < ActiveRecord::Migration
  def self.up
    items = Item.find(:all)
    i = 0
    for item in items do
      if item.code.blank?
		    item.update_attribute('code', "ITEM-#{i+=1}")
		  end
		end
  end

  def self.down
		# Can't really do anything
	end

end

