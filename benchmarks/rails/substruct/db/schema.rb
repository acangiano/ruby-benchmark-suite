# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 0) do

  create_table "content_node_types", :force => true do |t|
    t.string "name", :limit => 50, :default => "", :null => false
  end

  create_table "content_nodes", :force => true do |t|
    t.string   "name",       :limit => 200, :default => "", :null => false
    t.string   "title",      :limit => 100, :default => "", :null => false
    t.text     "content"
    t.datetime "display_on",                                :null => false
    t.datetime "created_on",                                :null => false
    t.string   "type",       :limit => 50,  :default => "", :null => false
  end

  add_index "content_nodes", ["name"], :name => "name"
  add_index "content_nodes", ["type", "id"], :name => "type"

  create_table "content_nodes_sections", :id => false, :force => true do |t|
    t.integer "content_node_id", :default => 0, :null => false
    t.integer "section_id",      :default => 0, :null => false
  end

  add_index "content_nodes_sections", ["content_node_id", "section_id"], :name => "default"

  create_table "countries", :force => true do |t|
    t.string  "name",        :limit => 100, :default => "",    :null => false
    t.string  "code",        :limit => 50
    t.integer "rank"
    t.boolean "is_obsolete",                :default => false, :null => false
  end

  create_table "items", :force => true do |t|
    t.string   "code",               :limit => 20,  :default => "",    :null => false
    t.string   "name",               :limit => 100, :default => "",    :null => false
    t.text     "description"
    t.float    "price",                             :default => 0.0,   :null => false
    t.datetime "date_available",                                       :null => false
    t.integer  "quantity",                          :default => 0,     :null => false
    t.float    "size_width",                        :default => 0.0,   :null => false
    t.float    "size_height",                       :default => 0.0,   :null => false
    t.float    "size_depth",                        :default => 0.0,   :null => false
    t.float    "weight",                            :default => 0.0,   :null => false
    t.string   "type",               :limit => 40
    t.integer  "product_id",                        :default => 0,     :null => false
    t.boolean  "is_discontinued",                   :default => false, :null => false
    t.integer  "variation_quantity",                :default => 0,     :null => false
  end

  add_index "items", ["date_available", "is_discontinued", "quantity", "variation_quantity", "type"], :name => "tag_view"
  add_index "items", ["name", "code", "is_discontinued", "date_available", "quantity", "variation_quantity", "type"], :name => "search"
  add_index "items", ["product_id", "type"], :name => "variation"
  add_index "items", ["quantity", "is_discontinued", "variation_quantity"], :name => "published"

  create_table "order_account_types", :force => true do |t|
    t.string "name", :limit => 30, :default => "", :null => false
  end

  create_table "order_accounts", :force => true do |t|
    t.integer "order_user_id",                       :default => 0, :null => false
    t.string  "order_user"
    t.integer "order_account_type_id",               :default => 1, :null => false
    t.string  "cc_number"
    t.string  "account_number"
    t.integer "expiration_month",      :limit => 2
    t.integer "expiration_year"
    t.integer "credit_ccv",            :limit => 8
    t.string  "routing_number",        :limit => 20
    t.string  "bank_name",             :limit => 50
  end

  add_index "order_accounts", ["order_user_id", "order_account_type_id"], :name => "ids"

  create_table "order_addresses", :force => true do |t|
    t.integer "order_user_id",               :default => 0,  :null => false
    t.string  "first_name",    :limit => 50, :default => "", :null => false
    t.string  "last_name",     :limit => 50, :default => "", :null => false
    t.string  "telephone",     :limit => 20
    t.string  "address",                     :default => "", :null => false
    t.string  "city",          :limit => 50
    t.string  "state",         :limit => 30
    t.string  "zip",           :limit => 10
    t.integer "country_id",                  :default => 0,  :null => false
  end

  add_index "order_addresses", ["country_id", "order_user_id"], :name => "countries"
  add_index "order_addresses", ["first_name", "last_name"], :name => "name"

  create_table "order_line_items", :force => true do |t|
    t.integer "item_id"
    t.integer "order_id",   :default => 0,   :null => false
    t.integer "quantity",   :default => 0,   :null => false
    t.float   "unit_price", :default => 0.0, :null => false
    t.string  "name",       :default => ""
  end

  create_table "order_shipping_types", :force => true do |t|
    t.string  "name",        :limit => 100, :default => "",   :null => false
    t.string  "code",        :limit => 50
    t.boolean "is_domestic",                :default => true, :null => false
    t.float   "price",                      :default => 0.0,  :null => false
  end

  create_table "order_shipping_weights", :force => true do |t|
    t.integer "order_shipping_type_id", :default => 0,   :null => false
    t.float   "min_weight",             :default => 0.0, :null => false
    t.float   "max_weight",             :default => 0.0, :null => false
    t.float   "price",                  :default => 0.0, :null => false
  end

  create_table "order_status_codes", :force => true do |t|
    t.string "name", :limit => 30, :default => "", :null => false
  end

  add_index "order_status_codes", ["name"], :name => "name"

  create_table "order_users", :force => true do |t|
    t.string   "username",      :limit => 50
    t.string   "email_address", :limit => 50, :default => "", :null => false
    t.string   "password",      :limit => 20
    t.datetime "created_on"
    t.string   "first_name",    :limit => 50, :default => "", :null => false
    t.string   "last_name",     :limit => 50, :default => "", :null => false
  end

  add_index "order_users", ["email_address"], :name => "email"

  create_table "orders", :force => true do |t|
    t.integer  "order_number",           :default => 0,   :null => false
    t.datetime "created_on"
    t.datetime "shipped_on"
    t.integer  "order_user_id"
    t.integer  "order_status_code_id",   :default => 1,   :null => false
    t.text     "notes"
    t.string   "referer"
    t.integer  "order_shipping_type_id", :default => 1,   :null => false
    t.float    "product_cost",           :default => 0.0
    t.float    "shipping_cost",          :default => 0.0
    t.float    "tax",                    :default => 0.0, :null => false
    t.string   "auth_transaction_id"
    t.integer  "promotion_id",           :default => 0,   :null => false
    t.integer  "shipping_address_id",    :default => 0,   :null => false
    t.integer  "billing_address_id",     :default => 0,   :null => false
    t.integer  "order_account_id",       :default => 0,   :null => false
  end

  add_index "orders", ["order_number"], :name => "order_number"
  add_index "orders", ["order_status_code_id"], :name => "status"
  add_index "orders", ["order_user_id"], :name => "order_user_id"

  create_table "plugin_schema_migrations", :id => false, :force => true do |t|
    t.string "plugin_name"
    t.string "version"
  end

  create_table "preferences", :force => true do |t|
    t.string "name",  :default => "", :null => false
    t.string "value", :default => ""
  end

  add_index "preferences", ["name"], :name => "namevalue"

  create_table "product_downloads", :force => true do |t|
    t.integer "download_id", :default => 0, :null => false
    t.integer "product_id",  :default => 0, :null => false
    t.integer "rank"
  end

  add_index "product_downloads", ["download_id"], :name => "did"
  add_index "product_downloads", ["product_id"], :name => "pid"

  create_table "product_images", :force => true do |t|
    t.integer "image_id",   :default => 0, :null => false
    t.integer "product_id", :default => 0, :null => false
    t.integer "rank"
  end

  add_index "product_images", ["product_id", "image_id"], :name => "main"

  create_table "products_tags", :id => false, :force => true do |t|
    t.integer "product_id", :default => 0, :null => false
    t.integer "tag_id",     :default => 0, :null => false
  end

  add_index "products_tags", ["product_id", "tag_id"], :name => "product_tags"

  create_table "promotions", :force => true do |t|
    t.string   "code",               :limit => 15, :default => "",  :null => false
    t.integer  "discount_type",                    :default => 0,   :null => false
    t.float    "discount_amount",                  :default => 0.0, :null => false
    t.integer  "item_id"
    t.datetime "start",                                             :null => false
    t.datetime "end",                                               :null => false
    t.float    "minimum_cart_value"
    t.string   "description",                      :default => "",  :null => false
  end

  create_table "questions", :force => true do |t|
    t.string   "short_question"
    t.text     "long_question"
    t.text     "answer"
    t.integer  "rank"
    t.boolean  "featured",                     :default => false, :null => false
    t.integer  "times_viewed",                 :default => 0,     :null => false
    t.datetime "created_on",                                      :null => false
    t.datetime "answered_on"
    t.string   "email_address",  :limit => 50
  end

  create_table "related_products", :id => false, :force => true do |t|
    t.integer "product_id", :default => 0, :null => false
    t.integer "related_id", :default => 0, :null => false
  end

  add_index "related_products", ["product_id", "related_id"], :name => "related_products"

  create_table "rights", :force => true do |t|
    t.string "name"
    t.string "controller"
    t.string "actions"
  end

  create_table "rights_roles", :id => false, :force => true do |t|
    t.integer "right_id"
    t.integer "role_id"
  end

  create_table "roles", :force => true do |t|
    t.string "name"
    t.text   "description"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  create_table "sections", :force => true do |t|
    t.string  "name",      :limit => 100, :default => "", :null => false
    t.integer "rank"
    t.integer "parent_id",                :default => 0,  :null => false
  end

  create_table "sessions", :force => true do |t|
    t.string   "sessid",     :default => "", :null => false
    t.text     "data"
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  add_index "sessions", ["sessid"], :name => "session_index"

  create_table "tags", :force => true do |t|
    t.string  "name",      :limit => 100, :default => "", :null => false
    t.integer "rank"
    t.integer "parent_id",                :default => 0,  :null => false
  end

  add_index "tags", ["name"], :name => "name"

  create_table "user_uploads", :force => true do |t|
    t.string   "filename"
    t.string   "attachment_file"
    t.integer  "width",           :default => 0, :null => false
    t.integer  "height",          :default => 0, :null => false
    t.string   "type"
    t.datetime "created_on"
    t.integer  "parent_id"
    t.string   "content_type"
    t.string   "thumbnail"
    t.integer  "size"
  end

  add_index "user_uploads", ["created_on", "type"], :name => "creation"

  create_table "users", :force => true do |t|
    t.string "login",    :limit => 50, :default => "", :null => false
    t.string "password", :limit => 40
  end

  add_index "users", ["login", "password"], :name => "login"

  create_table "wishlist_items", :force => true do |t|
    t.integer  "order_user_id", :default => 0, :null => false
    t.integer  "item_id",       :default => 0, :null => false
    t.datetime "created_on"
  end

  add_index "wishlist_items", ["item_id"], :name => "item"
  add_index "wishlist_items", ["order_user_id"], :name => "user"

end
