class AddTags < ActiveRecord::Migration
  def self.up
		# Adds a table for tags
		create_table "tags" do |t|
	    t.column "name", :string, :limit => 100, :default => "", :null => false
		end
		
		# Adds a table for storing tagged products
		create_table "products_tags", :id => false do |t|
	    t.column "product_id", :integer, :default => 0, :null => false
			t.column "tag_id", :integer, :default => 0, :null => false
		end
  end

  def self.down
		drop_table "tags"
		drop_table "products_tags"
  end
end
