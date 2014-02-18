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

ActiveRecord::Schema.define(:version => 20130822050724) do

  create_table "app_configs", :force => true do |t|
    t.string "key",         :limit => 40
    t.string "value"
    t.string "description"
  end

  create_table "categories", :force => true do |t|
    t.integer  "parent_id",          :default => 0,    :null => false
    t.integer  "categories_count",   :default => 0,    :null => false
    t.integer  "position",           :default => 0,    :null => false
    t.boolean  "enabled",            :default => true, :null => false
    t.string   "title",              :default => "",   :null => false
    t.string   "file_name",          :default => "",   :null => false
    t.string   "file_type",          :default => "",   :null => false
    t.boolean  "protected"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
  end

  create_table "categories_passwords", :id => false, :force => true do |t|
    t.integer "password_id"
    t.integer "category_id"
  end

  create_table "customers", :force => true do |t|
    t.string   "customer_name"
    t.string   "user_name"
    t.string   "company"
    t.string   "region"
    t.string   "currency"
    t.string   "customer_status"
    t.string   "password"
    t.string   "arrival_port"
    t.string   "terms"
    t.string   "delivery_terms"
    t.string   "contact_name"
    t.string   "phone"
    t.string   "position"
    t.string   "email"
    t.string   "add_phone"
    t.string   "fax"
    t.text     "notes"
    t.text     "street_1"
    t.text     "street_2"
    t.string   "city"
    t.string   "country"
    t.string   "province"
    t.string   "postal_code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "oc_code"
  end

  create_table "gallery_items", :force => true do |t|
    t.integer  "style_id",           :default => 0,  :null => false
    t.integer  "position",           :default => 0,  :null => false
    t.string   "name",               :default => "", :null => false
    t.string   "file_name",          :default => "", :null => false
    t.string   "file_type",          :default => "", :null => false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
  end

  create_table "media_files", :force => true do |t|
    t.integer "media_object_id",               :default => 0,  :null => false
    t.string  "file_name",                     :default => "", :null => false
    t.string  "file_type",       :limit => 50, :default => "", :null => false
  end

  create_table "media_holders", :force => true do |t|
    t.integer "parent_id", :default => 0
    t.string  "name",      :default => "", :null => false
  end

  create_table "media_objects", :force => true do |t|
    t.integer "media_type_id",   :default => 0,  :null => false
    t.integer "media_holder_id", :default => 0,  :null => false
    t.string  "name",            :default => "", :null => false
  end

  create_table "media_types", :force => true do |t|
    t.string "name",     :default => "", :null => false
    t.string "codename", :default => "", :null => false
  end

  create_table "navigation_items", :force => true do |t|
    t.integer "media_object_id",                       :default => 0,     :null => false
    t.integer "parent_id",                             :default => 0,     :null => false
    t.integer "position",                              :default => 0,     :null => false
    t.boolean "enabled",                               :default => true,  :null => false
    t.boolean "graphical",                             :default => false, :null => false
    t.integer "navigation_items_count",                :default => 0
    t.string  "name",                   :limit => 200, :default => "",    :null => false
    t.string  "url",                    :limit => 200, :default => "",    :null => false
    t.string  "hover_image",            :limit => 200, :default => "",    :null => false
    t.string  "current_image",          :limit => 200, :default => "",    :null => false
    t.string  "default_image",          :limit => 200, :default => "",    :null => false
  end

  create_table "order_product_details", :force => true do |t|
    t.integer  "order_id"
    t.string   "code"
    t.string   "description"
    t.string   "colour"
    t.string   "notes"
    t.boolean  "drainage"
    t.integer  "skid"
    t.integer  "pack"
    t.integer  "total"
    t.float    "price"
    t.float    "total_amount"
    t.integer  "barcode_number"
    t.integer  "bar_line_one"
    t.integer  "bar_line_two"
    t.integer  "bar_line_three"
    t.integer  "bar_line_four"
    t.string   "barcode_position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "orders", :force => true do |t|
    t.integer  "customer_id"
    t.string   "company"
    t.integer  "shipping_address_id"
    t.string   "customer_po"
    t.text     "sold_to"
    t.string   "sold_by"
    t.date     "requested_delivery"
    t.date     "requested_ship_date"
    t.date     "confirmed_ship_date"
    t.date     "eta_to_port"
    t.date     "eta_to_customer"
    t.date     "date_created"
    t.string   "order_confirmation"
    t.string   "status"
    t.text     "ship_to"
    t.string   "arrival_port"
    t.string   "terms"
    t.string   "delivery_terms"
    t.string   "mixed_full"
    t.text     "notes"
    t.string   "currency"
    t.string   "reference"
    t.string   "deposit_invoice"
    t.string   "deposit_date"
    t.string   "deposit_amount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "shipping_notes"
    t.integer  "add_ship_charge"
    t.float    "final_amount"
    t.date     "finished_date"
    t.integer  "updated_by",          :default => 1, :null => false
  end

  create_table "pages", :force => true do |t|
    t.integer "media_object_id",  :default => 0, :null => false
    t.integer "template_item_id", :default => 0, :null => false
    t.text    "content",                         :null => false
  end

  create_table "passwords", :force => true do |t|
    t.string "title", :default => "", :null => false
    t.string "value", :default => "", :null => false
  end

  create_table "permissions", :force => true do |t|
    t.string "name", :default => "", :null => false
  end

  create_table "permissions_roles", :id => false, :force => true do |t|
    t.integer "permission_id", :default => 0, :null => false
    t.integer "role_id",       :default => 0, :null => false
  end

  create_table "roles", :force => true do |t|
    t.string "codename",      :default => "",        :null => false
    t.string "name",          :default => "",        :null => false
    t.string "update_colour", :default => "#FFFFFF", :null => false
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "shipping_addresses", :force => true do |t|
    t.integer  "customer_id"
    t.string   "title"
    t.string   "receiver_name"
    t.string   "email"
    t.string   "phone"
    t.text     "notes"
    t.text     "street_1"
    t.text     "street_2"
    t.string   "city"
    t.string   "country"
    t.string   "province"
    t.string   "postal_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shipping_schedule_filters", :force => true do |t|
    t.integer  "role_id"
    t.string   "eta_to_port_after"
    t.string   "confirmed_shipdate_after"
    t.integer  "status"
    t.integer  "customer_id"
    t.string   "reference"
    t.integer  "mixed_full"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "eta_to_port_after_no_blanks"
    t.boolean  "confirmed_shipdate_after_no_blanks"
    t.boolean  "reference_no_blanks"
  end

  create_table "shipping_schedule_permissions", :force => true do |t|
    t.integer  "role_id"
    t.integer  "reference"
    t.integer  "date_created"
    t.integer  "status"
    t.integer  "customer_name"
    t.integer  "order_confirmation"
    t.integer  "requested_ship_date"
    t.integer  "requested_delivery"
    t.integer  "mixed_full"
    t.integer  "arrival_port"
    t.integer  "customer_city"
    t.integer  "confirmed_ship_date"
    t.integer  "eta_to_port"
    t.integer  "eta_to_customer"
    t.integer  "shipping_notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "finished_date"
    t.string   "edit_order_link"
    t.string   "edit_production_order_link"
    t.integer  "customer_po",                :default => 0, :null => false
  end

  create_table "specifications", :force => true do |t|
    t.integer "style_id",           :default => 0,    :null => false
    t.integer "position",           :default => 0,    :null => false
    t.string  "item",               :default => "",   :null => false
    t.string  "description",        :default => "",   :null => false
    t.string  "sp_style",           :default => "",   :null => false
    t.string  "colour",             :default => "",   :null => false
    t.string  "sp_type",            :default => "",   :null => false
    t.string  "vendor_specific",    :default => "",   :null => false
    t.string  "litres",             :default => "",   :null => false
    t.string  "us_gallons",         :default => "",   :null => false
    t.float   "od_ol_inch",         :default => 0.0,  :null => false
    t.string  "ow_inch",            :default => "",   :null => false
    t.string  "id_il_inch",         :default => "",   :null => false
    t.string  "iw_inch",            :default => "",   :null => false
    t.string  "ht_inch",            :default => "",   :null => false
    t.string  "bd_bl_inch",         :default => "",   :null => false
    t.string  "bw_inch",            :default => "",   :null => false
    t.string  "od_ol_cms",          :default => "",   :null => false
    t.string  "ow_cms",             :default => "",   :null => false
    t.string  "id_il_cms",          :default => "",   :null => false
    t.string  "iw_cms",             :default => "",   :null => false
    t.string  "ht_cms",             :default => "",   :null => false
    t.string  "bd_bl_cms",          :default => "",   :null => false
    t.string  "bw_cms",             :default => "",   :null => false
    t.string  "weight_grams",       :default => "",   :null => false
    t.string  "weight_pounds",      :default => "",   :null => false
    t.string  "bulk_skids",         :default => "",   :null => false
    t.string  "skids_container",    :default => "",   :null => false
    t.string  "skid_length_inch",   :default => "",   :null => false
    t.string  "skid_width_inch",    :default => "",   :null => false
    t.string  "skid_height_inch",   :default => "",   :null => false
    t.string  "skid_length_cm",     :default => "",   :null => false
    t.string  "skid_width_cm",      :default => "",   :null => false
    t.string  "skid_height_cm",     :default => "",   :null => false
    t.string  "skid_weight_pounds", :default => "",   :null => false
    t.boolean "drainage"
    t.boolean "visible",            :default => true
  end

  create_table "spreadsheet_fields", :force => true do |t|
    t.string   "name",       :default => "", :null => false
    t.string   "codename",   :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "spreadsheet_fields_users", :id => false, :force => true do |t|
    t.integer "spreadsheet_field_id"
    t.integer "user_id"
  end

  create_table "spreadsheet_log_items", :force => true do |t|
    t.integer  "user_id"
    t.string   "user_login"
    t.string   "ip"
    t.string   "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "spreadsheet_order_confirmation_rows", :force => true do |t|
    t.integer  "spreadsheet_row_id"
    t.string   "company",                    :default => "",    :null => false
    t.boolean  "company_highlight",          :default => false
    t.string   "order_code",                 :default => "",    :null => false
    t.boolean  "order_code_highlight",       :default => false
    t.date     "request_date"
    t.boolean  "request_date_highlight",     :default => false
    t.date     "delivery_date"
    t.boolean  "delivery_date_highlight",    :default => false
    t.string   "destination_city",           :default => "",    :null => false
    t.boolean  "destination_city_highlight", :default => false
    t.integer  "skid"
    t.boolean  "skid_highlight",             :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "spreadsheet_rows", :force => true do |t|
    t.boolean  "visible",                    :default => true
    t.text     "po"
    t.boolean  "po_highlight",               :default => false
    t.text     "cnee"
    t.boolean  "cnee_highlight",             :default => false
    t.text     "cntr"
    t.boolean  "cntr_highlight",             :default => false
    t.text     "mixed_port"
    t.boolean  "mixed_port_highlight",       :default => false
    t.text     "carrier"
    t.boolean  "carrier_highlight",          :default => false
    t.date     "mbcc"
    t.boolean  "mbcc_highlight",             :default => false
    t.text     "port_of_loading"
    t.boolean  "port_of_loading_highlight",  :default => false
    t.date     "request_shipdate"
    t.boolean  "request_shipdate_highlight", :default => false
    t.date     "etd"
    t.boolean  "etd_highlight",              :default => false
    t.date     "request_eta"
    t.boolean  "request_eta_highlight",      :default => false
    t.date     "eta_port"
    t.boolean  "eta_port_highlight",         :default => false
    t.text     "destination"
    t.boolean  "destination_highlight",      :default => false
    t.text     "door_address"
    t.boolean  "door_address_highlight",     :default => false
    t.text     "notes"
    t.boolean  "notes_highlight",            :default => false
    t.date     "delivery_date"
    t.boolean  "delivery_date_highlight",    :default => false
    t.text     "delivered"
    t.boolean  "delivered_highlight",        :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "oc_highlight",               :default => false
  end

  create_table "styles", :force => true do |t|
    t.integer  "category_id",          :default => 0,  :null => false
    t.integer  "position",             :default => 0,  :null => false
    t.string   "title",                :default => "", :null => false
    t.string   "file_name",            :default => "", :null => false
    t.string   "file_type",            :default => "", :null => false
    t.string   "palette_name",         :default => "", :null => false
    t.string   "palette_type",         :default => "", :null => false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "palette_file_name"
    t.string   "palette_content_type"
    t.integer  "palette_file_size"
    t.datetime "palette_updated_at"
    t.string   "image2_file_name"
    t.string   "image2_content_type"
    t.integer  "image2_file_size"
    t.datetime "image2_updated_at"
    t.string   "image3_file_name"
    t.string   "image3_content_type"
    t.integer  "image3_file_size"
    t.datetime "image3_updated_at"
  end

  create_table "template_items", :force => true do |t|
    t.string "name",     :default => "", :null => false
    t.string "codename", :default => "", :null => false
  end

  create_table "users", :force => true do |t|
    t.integer  "role_id",                           :default => 0,    :null => false
    t.string   "login",              :limit => 40
    t.string   "password",           :limit => 40
    t.string   "reset_password_key", :limit => 40
    t.boolean  "enabled",                           :default => true, :null => false
    t.string   "first_name",         :limit => 100, :default => "",   :null => false
    t.string   "last_name",          :limit => 100, :default => "",   :null => false
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",                    :default => "",   :null => false
    t.datetime "last_activity"
  end

end
