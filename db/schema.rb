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

ActiveRecord::Schema.define(version: 20141029160015) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cars", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "partner_id"
    t.integer  "slots"
    t.integer  "car_type",     default: 0
    t.integer  "user_id"
    t.string   "photo"
    t.string   "brand"
    t.string   "model"
    t.string   "color"
    t.string   "plate_number"
  end

  create_table "companies", force: true do |t|
    t.string   "name"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "address"
    t.string   "postcode"
    t.string   "city"
    t.string   "company_code"
    t.string   "tva_number"
    t.string   "bookmanager"
    t.integer  "partner_id"
  end

  create_table "companies_users", id: false, force: true do |t|
    t.integer "company_id"
    t.integer "user_id"
  end

  add_index "companies_users", ["company_id", "user_id"], name: "index_companies_users_on_company_id_and_user_id", using: :btree

  create_table "courses", force: true do |t|
    t.string   "from"
    t.string   "to"
    t.integer  "user_id",           default: 1
    t.integer  "partner_id",        default: 1
    t.integer  "car_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "nb_people",         default: 1
    t.integer  "status",            default: 0
    t.float    "computed_distance"
    t.float    "computed_price"
    t.json     "stops"
    t.integer  "created_by"
    t.date     "date_when"
    t.time     "time_when"
    t.string   "computed_duration"
    t.text     "notes"
    t.integer  "payment_when",      default: 0
    t.integer  "company_id",        default: 0
    t.string   "flight_number"
    t.boolean  "paid",              default: false
    t.datetime "paid_when"
    t.string   "paid_by__type"
    t.integer  "paid_by__id"
    t.integer  "nb_luggage"
  end

  create_table "notifications", force: true do |t|
    t.string   "title"
    t.text     "content"
    t.boolean  "seen",       default: false
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "notif_type", default: 0
  end

  create_table "partners", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
    t.text     "note"
    t.string   "company_code"
    t.string   "phone"
    t.string   "logo"
    t.string   "address"
    t.string   "postcode"
    t.string   "city"
    t.string   "status"
    t.string   "tva_number"
  end

  create_table "promocodes", force: true do |t|
    t.string   "name"
    t.integer  "effect_type",         default: 0
    t.integer  "effect_length",       default: 0
    t.integer  "effect_length_value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "effect_type_value"
    t.string   "code"
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_digest"
    t.integer  "account_type",    default: 0
    t.integer  "created_by"
    t.integer  "partner_id"
    t.integer  "company_id"
    t.string   "phone"
    t.decimal  "pos_lat"
    t.decimal  "pos_lon"
    t.string   "photo"
    t.string   "last_name"
    t.string   "address"
    t.string   "postcode"
    t.integer  "promocode_id"
    t.string   "city"
    t.string   "cellphone"
  end

end
