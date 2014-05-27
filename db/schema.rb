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

ActiveRecord::Schema.define(version: 20140527184145) do

  create_table "gambgames", force: true do |t|
    t.datetime "date_finished"
    t.float    "prize_paid"
    t.integer  "players_number"
    t.integer  "awards_won"
    t.integer  "winner_gambfruit_id"
    t.boolean  "ongoing"
    t.float    "current_prize"
    t.integer  "current_players_number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gambgames", ["winner_gambfruit_id"], name: "index_gambgames_on_winner_gambfruit_id", using: :btree

  create_table "join_requests", force: true do |t|
    t.integer  "user_id"
    t.integer  "receiver_id"
    t.boolean  "resolved"
    t.datetime "date_resolved"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "join_requests", ["receiver_id"], name: "index_join_requests_on_receiver_id", using: :btree
  add_index "join_requests", ["user_id"], name: "index_join_requests_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "full_name"
    t.date     "birth_date"
    t.integer  "seeds",                  default: 0
    t.integer  "coins",                  default: 0
    t.integer  "recommender_id"
    t.integer  "parent_id"
    t.integer  "left_branch_id"
    t.integer  "right_branch_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "username"
    t.boolean  "is_trunk"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["left_branch_id"], name: "index_users_on_left_branch_id", using: :btree
  add_index "users", ["parent_id"], name: "index_users_on_parent_id", using: :btree
  add_index "users", ["recommender_id"], name: "index_users_on_recommender_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["right_branch_id"], name: "index_users_on_right_branch_id", using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

end
