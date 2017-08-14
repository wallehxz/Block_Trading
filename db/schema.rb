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

ActiveRecord::Schema.define(version: 20170814020706) do

  create_table "balances", force: :cascade do |t|
    t.string   "block",      limit: 255
    t.float    "amount",     limit: 24
    t.float    "buy_price",  limit: 24
    t.float    "sell_price", limit: 24
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "block_tickers", force: :cascade do |t|
    t.integer  "block_id",   limit: 4
    t.float    "last_price", limit: 24
    t.float    "buy_price",  limit: 24
    t.float    "sell_price", limit: 24
    t.date     "that_date"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "blocks", force: :cascade do |t|
    t.string   "chinese",    limit: 255
    t.string   "english",    limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "focus_blocks", force: :cascade do |t|
    t.integer  "block_id",       limit: 4
    t.float    "buy_amount",     limit: 24
    t.float    "total_price",    limit: 24
    t.float    "sell_weights",   limit: 24
    t.float    "sell_amplitude", limit: 24
    t.boolean  "activation"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "frequency",      limit: 4,  default: 0
  end

  create_table "pending_orders", force: :cascade do |t|
    t.string   "block",      limit: 255
    t.string   "business",   limit: 255
    t.float    "amount",     limit: 24
    t.float    "price",      limit: 24
    t.float    "consume",    limit: 24
    t.integer  "state",      limit: 4,   default: 0
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.integer  "role",                   limit: 4,   default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
