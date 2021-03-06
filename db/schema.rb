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

ActiveRecord::Schema.define(version: 2019_05_05_181051) do

  create_table "fields", force: :cascade do |t|
    t.string "name"
    t.integer "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "racers", force: :cascade do |t|
    t.float "win_per"
    t.float "two_ren_per"
    t.float "three_ren_per"
    t.float "first_per"
    t.float "second_per"
    t.float "third_per"
    t.float "fourth_per"
    t.float "fifth_per"
    t.float "sixth_per"
    t.float "first_cource"
    t.float "second_cource"
    t.float "third_cource"
    t.float "fourth_cource"
    t.float "fifth_cource"
    t.float "sixth_cource"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "racer_number"
  end

  create_table "results", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "first_cource"
    t.float "second_cource"
    t.float "third_cource"
    t.float "fourth_cource"
    t.float "fifth_cource"
    t.float "sixth_cource"
    t.integer "field_id"
    t.integer "race_number"
    t.datetime "collect_date"
  end

end
