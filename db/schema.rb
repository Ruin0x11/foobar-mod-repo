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

ActiveRecord::Schema.define(version: 2019_03_27_224624) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "dependencies", force: :cascade do |t|
    t.bigint "mod_id"
    t.bigint "version_id"
    t.string "requirements"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["mod_id"], name: "index_dependencies_on_mod_id"
    t.index ["version_id"], name: "index_dependencies_on_version_id"
  end

  create_table "mods", force: :cascade do |t|
    t.string "identifier"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["identifier"], name: "index_mods_on_identifier", unique: true
    t.index ["user_id"], name: "index_mods_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "handle", null: false
    t.string "email", null: false
    t.string "encrypted_password", limit: 128, null: false
    t.string "confirmation_token", limit: 128
    t.string "remember_token", limit: 128, null: false
    t.index ["handle"], name: "index_users_on_handle"
    t.index ["remember_token"], name: "index_users_on_remember_token"
  end

  create_table "versions", force: :cascade do |t|
    t.string "number"
    t.string "name"
    t.string "authors"
    t.string "summary"
    t.string "licenses"
    t.bigint "download_count"
    t.integer "position"
    t.boolean "latest"
    t.bigint "mod_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["mod_id"], name: "index_versions_on_mod_id"
  end

  add_foreign_key "dependencies", "mods"
  add_foreign_key "dependencies", "versions"
  add_foreign_key "versions", "mods"
end