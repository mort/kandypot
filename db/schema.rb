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

ActiveRecord::Schema.define(:version => 20090618172719) do

  create_table "apps", :force => true do |t|
    t.string   "name"
    t.string   "nicename"
    t.string   "url"
    t.string   "app_key"
    t.string   "app_token"
    t.string   "ip",            :limit => 15
    t.text     "description"
    t.integer  "members_count",               :default => 0, :null => false
    t.integer  "kandies_count",               :default => 0, :null => false
    t.integer  "status",        :limit => 2,  :default => 1, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "apps", ["app_key"], :name => "index_apps_on_app_key", :unique => true
  add_index "apps", ["app_token"], :name => "index_apps_on_app_token", :unique => true
  add_index "apps", ["ip"], :name => "index_apps_on_ip", :unique => true
  add_index "apps", ["name"], :name => "index_apps_on_name", :unique => true
  add_index "apps", ["nicename"], :name => "index_apps_on_nicename", :unique => true
  add_index "apps", ["url"], :name => "index_apps_on_url", :unique => true

end