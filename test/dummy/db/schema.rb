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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130924132358) do

  create_table "chtests", :primary_key => "vm", :force => true do |t|
    t.string   "ch_str",     :default => "chstr", :null => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  create_table "sakes", :force => true do |t|
    t.string "commentator", :limit => 16,  :default => "", :null => false
    t.string "comment",     :limit => 128, :default => "", :null => false
  end

  create_table "vms", :force => true do |t|
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.string   "vmstr",      :default => "vmstr", :null => false
  end

end
