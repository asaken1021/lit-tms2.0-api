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

ActiveRecord::Schema.define(version: 2020_07_12_054915) do

  create_table "groups", force: :cascade do |t|
    t.string "name"
    t.string "description"
  end

  create_table "nonces", force: :cascade do |t|
    t.string "nonces"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "phases", force: :cascade do |t|
    t.string "name"
    t.integer "project_id"
    t.date "deadline"
  end

  create_table "projects", force: :cascade do |t|
    t.string "name"
    t.integer "user_id"
    t.float "progress"
    t.string "visibility", default: "public"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tasks", force: :cascade do |t|
    t.string "name"
    t.string "memo"
    t.integer "progress"
    t.integer "project_id"
    t.integer "phase_id"
  end

  create_table "user_activities", force: :cascade do |t|
    t.integer "user_id"
    t.integer "project_id"
    t.integer "phase_id"
    t.integer "task_id"
    t.string "activity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_days", force: :cascade do |t|
    t.integer "user_id"
    t.integer "day_id"
  end

  create_table "user_groups", force: :cascade do |t|
    t.integer "user_id"
    t.integer "group_id"
  end

  create_table "user_times", force: :cascade do |t|
    t.integer "user_id"
    t.integer "time_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "mail"
    t.string "name"
    t.string "password_digest"
    t.string "user_line_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
