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

ActiveRecord::Schema.define(version: 20140731000024) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "steam_games", force: true do |t|
    t.integer  "app_id",        limit: 8, null: false
    t.string   "title",                   null: false
    t.text     "header_image"
    t.text     "capsule_image"
    t.text     "categories"
    t.boolean  "multi_player"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "steam_games", ["app_id"], name: "index_steam_games_on_app_id", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.integer  "uid",        limit: 8
    t.string   "nickname"
    t.string   "image"
    t.text     "friends"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["uid"], name: "index_users_on_uid", unique: true, using: :btree

end
