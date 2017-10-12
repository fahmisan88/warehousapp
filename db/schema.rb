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

<<<<<<< HEAD
ActiveRecord::Schema.define(version: 20170930093857) do
=======
ActiveRecord::Schema.define(version: 20171008135709) do
>>>>>>> staging

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activities", force: :cascade do |t|
    t.string   "trackable_type"
    t.integer  "trackable_id"
    t.string   "owner_type"
    t.integer  "owner_id"
    t.string   "key"
    t.text     "parameters"
    t.string   "recipient_type"
    t.integer  "recipient_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type", using: :btree
    t.index ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type", using: :btree
    t.index ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type", using: :btree
  end

  create_table "currencies", force: :cascade do |t|
    t.decimal  "myr2rmb"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal  "rmb2myr"
  end

  create_table "ordered_parcels", force: :cascade do |t|
    t.integer  "parcel_id"
    t.integer  "shipment_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "parcels", force: :cascade do |t|
    t.string   "awb"
    t.string   "description"
    t.string   "remark"
    t.string   "image"
    t.integer  "user_id"
    t.decimal  "weight",              default: "0.5"
    t.decimal  "volume"
    t.integer  "status",              default: 0
    t.integer  "parcel_good"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.boolean  "photoshoot"
    t.boolean  "inspection"
    t.integer  "product_quantity"
    t.decimal  "price_per_unit"
    t.decimal  "product_total_price"
    t.string   "product_chinese"
    t.string   "new_awb"
    t.string   "image1"
    t.string   "image2"
    t.string   "image3"
    t.string   "image4"
    t.string   "image5"
    t.decimal  "width",               default: "1.0"
    t.decimal  "length",              default: "1.0"
    t.decimal  "height",              default: "1.0"
    t.decimal  "chargeable"
    t.boolean  "refund"
    t.string   "refund_explain"
    t.datetime "free_storage"
    t.decimal  "final_kg"
    t.string   "remark_admin"
    t.string   "ezi_id"
    t.json     "images"
    t.string   "inspection_detail"
  end

  create_table "shipments", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "remark"
    t.integer  "status"
    t.integer  "shipment_type"
    t.decimal  "charge"
    t.string   "bill_id"
    t.datetime "due_at"
    t.datetime "paid_at"
    t.string   "bill_url"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.boolean  "reorganize"
    t.boolean  "repackaging"
    t.boolean  "sea_freight",      default: false
    t.integer  "final_kg"
    t.integer  "extra_charge",     default: 0
    t.string   "extra_remark"
    t.integer  "minus_charge",     default: 0
    t.decimal  "sea_charge"
    t.string   "remark_admin"
    t.string   "ezi_id"
    t.string   "tracking"
    t.decimal  "air_charge"
    t.string   "cbm"
    t.decimal  "transport_charge"
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "password_digest"
    t.text     "address"
    t.string   "postcode"
    t.string   "phone"
    t.integer  "role",                   default: 0
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "address2"
    t.integer  "status",                 default: 0
    t.string   "bill_id"
    t.string   "bill_url"
    t.decimal  "ewallet"
    t.integer  "package"
    t.datetime "expiry"
    t.string   "ezi_id"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "releasesuspend_at"
<<<<<<< HEAD
    t.string   "icpassport"
=======
    t.string   "city"
>>>>>>> staging
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["ezi_id"], name: "index_users_on_ezi_id", using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

end
