# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2025_10_27_081334) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "transactions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "sender_user_id"
    t.uuid "receiver_user_id"
    t.string "sender_currency"
    t.string "receiver_currency"
    t.decimal "transaction_amount", precision: 25, scale: 10, null: false
    t.decimal "currency_conversion_rate", precision: 25, scale: 10, null: false
    t.decimal "currency_conversion_fee", precision: 25, scale: 10, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["receiver_user_id"], name: "index_transactions_on_receiver_user_id"
    t.index ["sender_user_id", "receiver_user_id"], name: "index_transactions_on_sender_user_id_and_receiver_user_id"
    t.index ["sender_user_id"], name: "index_transactions_on_sender_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.integer "age", null: false
    t.string "mobile", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "wallets", id: false, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "currency", null: false
    t.decimal "balance", precision: 25, scale: 10, default: "0.0", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id", "currency"], name: "index_wallets_on_user_id_and_currency", unique: true
  end

  add_foreign_key "transactions", "users", column: "receiver_user_id"
  add_foreign_key "transactions", "users", column: "sender_user_id"
  add_foreign_key "wallets", "users"
end
