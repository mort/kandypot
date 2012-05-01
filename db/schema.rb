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

ActiveRecord::Schema.define(:version => 20120413083839) do

  create_table "activities", :force => true do |t|
    t.integer  "app_id"
    t.datetime "processed_at"
    t.integer  "proccessing_status",  :limit => 2
    t.string   "ip",                  :limit => 15, :null => false
    t.string   "category",            :limit => 25, :null => false
    t.string   "uuid",                :limit => 36, :null => false
    t.datetime "published",                         :null => false
    t.string   "actor_token",         :limit => 32, :null => false
    t.string   "verb",                              :null => false
    t.string   "object_type"
    t.string   "object_url"
    t.string   "target_type"
    t.string   "target_token",        :limit => 32
    t.string   "target_url"
    t.string   "target_author_token", :limit => 32
    t.string   "mood",                :limit => 25
    t.integer  "intensity",           :limit => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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

  create_table "badge_grants", :force => true do |t|
    t.integer  "badge_id"
    t.integer  "member_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "activity_uuid", :limit => 36, :null => false
  end

  create_table "badges", :force => true do |t|
    t.integer  "app_id"
    t.string   "badge_type"
    t.string   "title"
    t.string   "description"
    t.text     "params"
    t.integer  "status",          :limit => 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "category"
    t.string   "verb"
    t.string   "predicate_types"
    t.integer  "qtty"
    t.string   "variant"
    t.string   "period_type",     :limit => 2
    t.string   "period_variant",  :limit => 2
    t.integer  "badge_scope",     :limit => 2
    t.boolean  "repeatable",                   :default => false, :null => false
    t.float    "p",                            :default => 1.0,   :null => false
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.string   "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "kandies", :force => true do |t|
    t.string   "uuid",       :limit => 36, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "kandy_ownerships", :force => true do |t|
    t.integer  "member_id"
    t.integer  "kandy_id"
    t.integer  "status",        :limit => 1,  :default => 1, :null => false
    t.datetime "expired_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "activity_uuid", :limit => 36,                :null => false
  end

  add_index "kandy_ownerships", ["kandy_id", "status"], :name => "index_kandy_ownerships_on_kandy_id_and_status"

  create_table "members", :force => true do |t|
    t.integer  "app_id"
    t.string   "member_token",           :default => "", :null => false
    t.integer  "deposits_count",         :default => 0,  :null => false
    t.integer  "transfers_count",        :default => 0,  :null => false
    t.integer  "kandies_count",          :default => 0,  :null => false
    t.integer  "kandy_ownerships_count", :default => 0,  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "members", ["app_id", "kandies_count"], :name => "members_app_id_kandies_count"
  add_index "members", ["member_token", "app_id"], :name => "members_member_token_app_id"
  add_index "members", ["member_token"], :name => "index_members_on_member_token", :unique => true

  create_table "notifications", :force => true do |t|
    t.integer  "app_id"
    t.string   "title",      :default => "", :null => false
    t.text     "body",                       :null => false
    t.string   "category",   :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notifications", ["app_id"], :name => "index_notifications_on_app_id"

  create_table "operation_logs", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "activity_id"
    t.integer  "app_id"
    t.text     "data"
    t.datetime "executed_at"
  end

  add_index "operation_logs", ["app_id"], :name => "index_operation_logs_on_app_id"

end
