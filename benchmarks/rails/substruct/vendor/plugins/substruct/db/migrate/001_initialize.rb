class Initialize < ActiveRecord::Migration
  def self.up
    create_table(:content_node_types, :options => 'DEFAULT CHARSET=UTF8 ENGINE=InnoDB') do |t|
      t.column "name", :string, :limit => 50, :default => "", :null => false
    end

    create_table(:content_nodes, :options => 'DEFAULT CHARSET=UTF8 ENGINE=InnoDB') do |t|
      t.column "name", :string, :limit => 200, :default => "", :null => false
      t.column "title", :string, :limit => 100, :default => "", :null => false
      t.column "content", :text, :null => false
      t.column "display_on", :datetime, :null => false
      t.column "created_on", :datetime, :null => false
      t.column "content_node_type_id", :integer, :default => 1, :null => false
    end

    add_index 'content_nodes', ["name"], :name => "name"

    create_table(:countries, :options => 'DEFAULT CHARSET=UTF8 ENGINE=InnoDB') do |t|
      t.column "name", :string, :limit => 100, :default => "", :null => false
      t.column "fedex_code", :string, :limit => 50
      t.column "ufsi_code", :string, :limit => 3
      t.column "number_of_orders", :integer, :default => 0, :null => false
    end

    add_index 'countries', ["number_of_orders"], :name => "number_of_orders"

    create_table(:images, :options => 'DEFAULT CHARSET=UTF8 ENGINE=InnoDB') do |t|
      t.column "path", :string, :default => "", :null => false
      t.column "description", :string
      t.column "width", :integer, :default => 0, :null => false
      t.column "height", :integer, :default => 0, :null => false
    end

    create_table(:images_products, :options => 'DEFAULT CHARSET=UTF8 ENGINE=InnoDB', :id => false) do |t|
      t.column "image_id", :integer, :default => 0, :null => false
      t.column "product_id", :integer, :default => 0, :null => false
    end

    add_index 'images_products', ["product_id", "image_id"], :name => "main"

    create_table(:order_account_types, :options => 'DEFAULT CHARSET=UTF8 ENGINE=InnoDB') do |t|
      t.column "name", :string, :limit => 30, :default => "", :null => false
    end

    create_table(:order_accounts, :options => 'DEFAULT CHARSET=UTF8 ENGINE=InnoDB') do |t|
      t.column "order_user_id", :integer, :default => 0, :null => false
      t.column "order_address_id", :integer, :default => 0, :null => false
      t.column "order_account_type_id", :integer, :default => 1, :null => false
      t.column "cc_number", :string, :limit => 17
      t.column "account_number", :string, :limit => 20
      t.column "expiration_month", :integer, :limit => 2
      t.column "expiration_year", :integer, :limit => 4
      t.column "credit_ccv", :integer, :limit => 5
      t.column "routing_number", :string, :limit => 20
      t.column "bank_name", :string, :limit => 50
    end

    add_index "order_accounts", ["order_user_id", "order_address_id", "order_account_type_id"], :name => "ids"

    create_table(:order_addresses, :options => 'DEFAULT CHARSET=UTF8 ENGINE=InnoDB') do |t|
      t.column "order_user_id", :integer, :default => 0, :null => false
      t.column "is_shipping", :boolean, :default => false, :null => false
      t.column "first_name", :string, :limit => 50, :default => "", :null => false
      t.column "last_name", :string, :limit => 50, :default => "", :null => false
      t.column "telephone", :string, :limit => 20
      t.column "address", :string, :default => "", :null => false
      t.column "city", :string, :limit => 50
      t.column "state", :string, :limit => 10
      t.column "zip", :string, :limit => 10
      t.column "country_id", :integer, :default => 0, :null => false
    end

    add_index "order_addresses", ["first_name", "last_name"], :name => "name"

    create_table(:order_line_items, :options => 'DEFAULT CHARSET=UTF8 ENGINE=InnoDB') do |t|
      t.column "product_id", :integer, :default => 0, :null => false
      t.column "order_id", :integer, :default => 0, :null => false
      t.column "quantity", :integer, :default => 0, :null => false
      t.column "unit_price", :float, :limit => 10, :default => 0.0, :null => false
    end

    create_table(:order_shipping_types, :options => 'DEFAULT CHARSET=UTF8 ENGINE=InnoDB') do |t|
      t.column "name", :string, :limit => 100, :default => "", :null => false
      t.column "code", :string, :limit => 50
      t.column "company", :string, :limit => 20
      t.column "is_domestic", :boolean, :default => false, :null => false
      t.column "service_type", :string, :limit => 50
      t.column "transaction_type", :string, :limit => 50
      t.column "shipping_multiplier", :float, :limit => 10, :default => 0.0, :null => false
      t.column "flat_fee", :float, :limit => 10, :default => 0.0, :null => false
    end

    create_table(:order_status_codes, :options => 'DEFAULT CHARSET=UTF8 ENGINE=InnoDB') do |t|
      t.column "name", :string, :limit => 30, :default => "", :null => false
    end

    add_index "order_status_codes", ["name"], :name => "name"

    create_table(:order_users, :options => 'DEFAULT CHARSET=UTF8 ENGINE=InnoDB') do |t|
      t.column "username", :string, :limit => 50
      t.column "email_address", :string, :limit => 50, :default => "", :null => false
      t.column "password", :string, :limit => 20
      t.column "created_on", :datetime
    end

    add_index "order_users", ["email_address"], :name => "email"

    create_table(:orders, :options => 'DEFAULT CHARSET=UTF8 ENGINE=InnoDB') do |t|
      t.column "order_number", :integer, :default => 0, :null => false
      t.column "created_on", :datetime
      t.column "shipped_on", :datetime
      t.column "order_user_id", :integer
      t.column "order_status_code_id", :integer, :default => 1, :null => false
      t.column "notes", :text
      t.column "referer", :string
      t.column "order_shipping_type_id", :integer, :default => 1, :null => false
      t.column "product_cost", :float, :limit => 10, :default => 0.0
      t.column "shipping_cost", :float, :limit => 10, :default => 0.0
      t.column "tax", :float, :limit => 5
    end

    add_index "orders", ["order_number"], :name => "order_number"
    add_index "orders", ["order_user_id"], :name => "order_user_id"
    add_index "orders", ["order_status_code_id"], :name => "status"

    create_table(:products, :options => 'DEFAULT CHARSET=UTF8 ENGINE=InnoDB') do |t|
      t.column "code", :string, :limit => 20, :default => "", :null => false
      t.column "name", :string, :limit => 100, :default => "", :null => false
      t.column "description", :text, :null => false
      t.column "price", :float, :limit => 10, :default => 0.0, :null => false
      t.column "date_available", :datetime, :null => false
      t.column "quantity", :integer, :default => 0, :null => false
      t.column "size_width", :float, :limit => 10, :default => 0.0, :null => false
      t.column "size_height", :float, :limit => 10, :default => 0.0, :null => false
      t.column "size_depth", :float, :limit => 10, :default => 0.0, :null => false
      t.column "weight", :float, :limit => 10, :default => 0.0, :null => false
    end

    create_table(:questions, :options => 'DEFAULT CHARSET=UTF8 ENGINE=InnoDB') do |t|
      t.column "short_question", :string
      t.column "long_question", :text, :null => false
      t.column "answer", :text
      t.column "rank", :integer
      t.column "featured", :boolean, :default => false, :null => false
      t.column "times_viewed", :integer, :default => 0, :null => false
      t.column "created_on", :datetime, :null => false
      t.column "answered_on", :datetime
    end

    create_table "sessions" do |t|
      t.column "sessid", :string, :default => "", :null => false
      t.column "data", :text, :null => false
      t.column "updated_at", :datetime
      t.column "created_at", :datetime
    end

    add_index "sessions", ["sessid"], :name => "session_index"

    create_table(:users, :options => 'DEFAULT CHARSET=UTF8 ENGINE=InnoDB') do |t|
      t.column "login", :string, :limit => 50, :default => "", :null => false
      t.column "password", :string, :limit => 40
    end

    add_index "users", ["login", "password"], :name => "login"
    
    # Load authority data
    puts "\n\nLoading authority data..."
    Rake::Task['load_authority_data'].invoke
    puts "...authority data loaded."
  end

  def self.down
    drop_table :content_node_types
    drop_table :content_nodes
    drop_table :countries
    drop_table :images
    drop_table :images_products
    drop_table :order_accounts
    drop_table :order_account_types
    drop_table :order_addresses
    drop_table :order_line_items
    drop_table :order_shipping_types
    drop_table :order_status_codes
    drop_table :order_users
    drop_table :orders
    drop_table :products
    drop_table :questions
    drop_table :sessions
    drop_table :users
  end
end
