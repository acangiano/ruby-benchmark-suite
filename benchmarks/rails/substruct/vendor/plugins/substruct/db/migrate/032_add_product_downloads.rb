# Adds table necessary to link uploaded files with products.
#
class AddProductDownloads < ActiveRecord::Migration
  def self.up
    create_table "product_downloads", :force => true do |t|
      t.integer "download_id", :default => 0, :null => false
      t.integer "product_id", :default => 0, :null => false
      t.integer "rank", :limit => 11
    end
    add_index "product_downloads", ["product_id"], :name => "pid"
    add_index "product_downloads", ["download_id"], :name => "did"
  end
  
  def self.down
    drop_table :product_downloads
  end

end
