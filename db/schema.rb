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

ActiveRecord::Schema.define(version: 20150819144101) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "forum_permissions", force: :cascade do |t|
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.boolean  "inherit",                  default: true,  null: false
    t.integer  "group_id"
    t.integer  "forum_id"
    t.boolean  "view_forum",               default: true,  null: false
    t.boolean  "view_topic",               default: true,  null: false
    t.boolean  "preapproved_posts",        default: true,  null: false
    t.boolean  "create_topic",             default: true,  null: false
    t.boolean  "create_post",              default: true,  null: false
    t.boolean  "edit_own_post",            default: true,  null: false
    t.boolean  "soft_delete_own_post",     default: false, null: false
    t.boolean  "hard_delete_own_post",     default: false, null: false
    t.boolean  "lock_or_unlock_own_topic", default: false, null: false
    t.boolean  "copy_or_move_own_topic",   default: false, null: false
    t.boolean  "edit_any_post",            default: false, null: false
    t.boolean  "soft_delete_any_post",     default: false, null: false
    t.boolean  "hard_delete_any_post",     default: false, null: false
    t.boolean  "lock_or_unlock_any_topic", default: false, null: false
    t.boolean  "copy_or_move_any_topic",   default: false, null: false
    t.boolean  "manage_any_content",       default: false, null: false
  end

  create_table "forums", force: :cascade do |t|
    t.string   "title"
    t.string   "slug"
    t.integer  "views_count", default: 0
    t.integer  "forum_id"
    t.boolean  "locked",      default: false, null: false
    t.boolean  "hidden",      default: false, null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "description"
  end

  create_table "groups", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "description"
    t.boolean  "create_forum",             default: false, null: false
    t.boolean  "view_forum",               default: true,  null: false
    t.boolean  "view_topic",               default: true,  null: false
    t.boolean  "preapproved_posts",        default: true,  null: false
    t.boolean  "create_post",              default: true,  null: false
    t.boolean  "edit_own_post",            default: true,  null: false
    t.boolean  "soft_delete_own_post",     default: false, null: false
    t.boolean  "hard_delete_own_post",     default: false, null: false
    t.boolean  "create_topic",             default: true,  null: false
    t.boolean  "lock_or_unlock_own_topic", default: false, null: false
    t.boolean  "copy_or_move_own_topic",   default: false, null: false
    t.boolean  "edit_any_post",            default: false, null: false
    t.boolean  "soft_delete_any_post",     default: false, null: false
    t.boolean  "hard_delete_any_post",     default: false, null: false
    t.boolean  "lock_or_unlock_any_topic", default: false, null: false
    t.boolean  "copy_or_move_any_topic",   default: false, null: false
    t.boolean  "moderate_any_forum",       default: false, null: false
  end

  create_table "posts", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "topic_id"
    t.text     "body",                             null: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "state",        default: "visible"
    t.integer  "moderator_id"
    t.string   "mod_reason"
  end

  create_table "topics", force: :cascade do |t|
    t.integer  "forum_id"
    t.string   "title"
    t.string   "slug"
    t.boolean  "locked",       default: false,     null: false
    t.boolean  "hidden",       default: false,     null: false
    t.boolean  "pinned",       default: false,     null: false
    t.integer  "views_count"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "user_id"
    t.datetime "last_post_at"
    t.string   "state",        default: "visible"
  end

  create_table "user_groups", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
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
    t.string   "username",                            null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "birthday"
    t.string   "time_zone"
    t.string   "country"
    t.string   "quote"
    t.string   "website"
    t.text     "bio"
    t.text     "signature"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "views", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "viewable_id"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "count",             default: 0
    t.string   "viewable_type"
    t.datetime "current_viewed_at"
    t.datetime "past_viewed_at"
  end

  add_foreign_key "forums", "forums"
  add_foreign_key "posts", "topics", on_delete: :cascade
  add_foreign_key "posts", "users"
  add_foreign_key "topics", "forums"
  add_foreign_key "topics", "users"
  add_foreign_key "user_groups", "groups"
  add_foreign_key "user_groups", "users"
  add_foreign_key "views", "users"
end
