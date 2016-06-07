# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160607154003) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "loads", force: :cascade do |t|
    t.date     "delivery_date"
    t.integer  "shift",            default: 1
    t.float    "volume",           default: 0.0,   null: false
    t.integer  "quantity",         default: 0,     null: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.float    "reverse_volume",   default: 0.0,   null: false
    t.integer  "reverse_quantity", default: 0,     null: false
    t.boolean  "completed",        default: false
  end

  add_index "loads", ["delivery_date", "shift"], name: "index_loads_on_delivery_date_and_shift", using: :btree
  add_index "loads", ["delivery_date"], name: "index_loads_on_delivery_date", using: :btree

  create_table "locations", force: :cascade do |t|
    t.string   "name"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.string   "zip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "locations", ["address"], name: "index_locations_on_address", using: :btree
  add_index "locations", ["name"], name: "index_locations_on_name", using: :btree

  create_table "orders", force: :cascade do |t|
    t.string   "number"
    t.float    "volume",         default: 0.0
    t.integer  "quantity",       default: 0
    t.integer  "origin_id"
    t.integer  "destination_id"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "phone"
    t.integer  "load_id"
    t.integer  "position"
    t.boolean  "reverse",        default: false
    t.date     "delivery_date"
    t.integer  "shift",          default: 0
  end

  add_index "orders", ["destination_id"], name: "index_orders_on_destination_id", using: :btree
  add_index "orders", ["load_id"], name: "index_orders_on_load_id", using: :btree
  add_index "orders", ["number"], name: "index_orders_on_number", using: :btree
  add_index "orders", ["origin_id"], name: "index_orders_on_origin_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",            null: false
    t.string   "crypted_password"
    t.string   "salt"
    t.string   "role"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "truck_number"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

end
