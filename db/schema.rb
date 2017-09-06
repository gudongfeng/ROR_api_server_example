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

ActiveRecord::Schema.define(version: 20170809185231) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "appointments", force: :cascade do |t|
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "tutor_id"
    t.bigint "student_id"
    t.integer "student_rating"
    t.text "student_feedback"
    t.text "tutor_feedback"
    t.string "pay_state", default: "unpaid"
    t.string "order_no"
    t.string "conference_name"
    t.integer "tutor_rating"
    t.string "student_call_uuid"
    t.string "tutor_call_uuid"
    t.string "student_sidekiq_job_id"
    t.string "tutor_sidekiq_job_id"
    t.string "hard_worker"
    t.string "call_hangup"
    t.integer "plan_id"
    t.decimal "tutor_earned", precision: 8, scale: 2
    t.bigint "discount_id"
    t.integer "student_call_duration"
    t.integer "tutor_call_duration"
    t.decimal "amount", precision: 8, scale: 2
    t.index ["discount_id"], name: "index_appointments_on_discount_id"
    t.index ["order_no"], name: "index_appointments_on_order_no", unique: true
    t.index ["student_id"], name: "index_appointments_on_student_id"
    t.index ["tutor_id"], name: "index_appointments_on_tutor_id"
  end

  create_table "certificates", force: :cascade do |t|
    t.string "name"
    t.string "picture_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "level"
    t.integer "requirement_num"
    t.text "description"
    t.string "origin_picture_url"
  end

  create_table "discounts", force: :cascade do |t|
    t.string "value"
    t.integer "count"
    t.string "company_logo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "rate"
    t.string "discount_rate_chinese"
  end

  create_table "educations", force: :cascade do |t|
    t.string "school"
    t.string "major"
    t.string "degree"
    t.date "start_time"
    t.date "end_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "tutor_id"
    t.index ["tutor_id"], name: "index_educations_on_tutor_id"
  end

  create_table "rpush_apps", force: :cascade do |t|
    t.string "name", null: false
    t.string "environment"
    t.text "certificate"
    t.string "password"
    t.integer "connections", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type", null: false
    t.string "auth_key"
    t.string "client_id"
    t.string "client_secret"
    t.string "access_token"
    t.datetime "access_token_expiration"
  end

  create_table "rpush_feedback", force: :cascade do |t|
    t.string "device_token", limit: 64, null: false
    t.datetime "failed_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "app_id"
    t.index ["device_token"], name: "index_rpush_feedback_on_device_token"
  end

  create_table "rpush_notifications", force: :cascade do |t|
    t.integer "badge"
    t.string "device_token", limit: 64
    t.string "sound", default: "default"
    t.string "alert"
    t.text "data"
    t.integer "expiry", default: 86400
    t.boolean "delivered", default: false, null: false
    t.datetime "delivered_at"
    t.boolean "failed", default: false, null: false
    t.datetime "failed_at"
    t.integer "error_code"
    t.text "error_description"
    t.datetime "deliver_after"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "alert_is_json", default: false
    t.string "type", null: false
    t.string "collapse_key"
    t.boolean "delay_while_idle", default: false, null: false
    t.text "registration_ids"
    t.integer "app_id", null: false
    t.integer "retries", default: 0
    t.string "uri"
    t.datetime "fail_after"
    t.boolean "processing", default: false, null: false
    t.integer "priority"
    t.text "url_args"
    t.string "category"
    t.index ["delivered", "failed"], name: "index_rpush_notifications_multi", where: "((NOT delivered) AND (NOT failed))"
  end

  create_table "students", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "phoneNumber"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "password_digest"
    t.decimal "balance", precision: 8, scale: 2
    t.boolean "activated", default: false
    t.datetime "activated_at"
    t.string "reset_digest"
    t.datetime "reset_sent_at"
    t.integer "session_count", default: 1
    t.integer "prioritized_tutor"
    t.string "state"
    t.string "remark1"
    t.string "device_token"
    t.integer "current_request"
    t.string "picture"
    t.string "verification_code"
    t.integer "country_code"
    t.string "gender"
    t.index ["email"], name: "index_students_on_email", unique: true
    t.index ["phoneNumber"], name: "index_students_on_phoneNumber", unique: true
  end

  create_table "tutors", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.string "country"
    t.string "picture"
    t.string "region"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "description"
    t.decimal "balance", precision: 8, scale: 2
    t.string "phoneNumber"
    t.string "activation_digest"
    t.boolean "activated", default: false
    t.datetime "activated_at"
    t.string "reset_digest"
    t.datetime "reset_sent_at"
    t.string "device_token"
    t.integer "current_request"
    t.string "tutor_timer_job_id"
    t.integer "level"
    t.string "gender"
    t.integer "country_code"
    t.string "verification_code"
    t.integer "decline_count"
    t.index ["email"], name: "index_tutors_on_email", unique: true
    t.index ["phoneNumber"], name: "index_tutors_on_phoneNumber", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.string "name"
    t.string "app_type"
    t.boolean "force_update"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "appointments", "discounts"
  add_foreign_key "appointments", "students"
  add_foreign_key "appointments", "tutors"
  add_foreign_key "educations", "tutors"
end
