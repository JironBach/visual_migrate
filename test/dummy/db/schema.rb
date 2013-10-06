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

ActiveRecord::Schema.define(version: 20131006135044) do

  create_table "cds", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "chstr",                 default: "chstr", null: false
    t.float    "chfloat",    limit: 10, default: 0.0,     null: false
  end

  create_table "ch2", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "chstr",      default: "chstr", null: false
  end

  create_table "chtests", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sakes", force: true do |t|
    t.string "commentator", limit: 16,  default: "", null: false
    t.string "comment",     limit: 128, default: "", null: false
  end

  create_table "test_tables", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "visual_migrate_schema_migrations", force: true do |t|
    t.string "version", null: false
  end

  create_table "vms", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "vmstr",      default: "vmstr", null: false
  end

end
