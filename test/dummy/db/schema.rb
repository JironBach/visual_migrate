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

ActiveRecord::Schema.define(version: 20131011134705) do

  create_table "master_ages", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "value",      limit: 16, null: false
  end

  create_table "testes_tables", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title",      limit: 64, default: "abc", null: false
    t.text     "contents"
  end

  create_table "visual_migrate_schema_migrations", force: true do |t|
    t.string "version", null: false
  end

end
