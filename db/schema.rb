# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_06_04_035020) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "activities", force: :cascade do |t|
    t.string "trackable_type", null: false
    t.bigint "trackable_id", null: false
    t.bigint "company_id", null: false
    t.bigint "user_id", null: false
    t.string "action", null: false
    t.jsonb "metadata", default: {}
    t.datetime "occurred_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["action"], name: "index_activities_on_action"
    t.index ["company_id", "action"], name: "index_activities_on_company_id_and_action"
    t.index ["company_id", "occurred_at"], name: "index_activities_on_company_id_and_occurred_at"
    t.index ["company_id"], name: "index_activities_on_company_id"
    t.index ["metadata"], name: "index_activities_on_metadata"
    t.index ["occurred_at"], name: "index_activities_on_occurred_at"
    t.index ["trackable_type", "trackable_id"], name: "index_activities_on_trackable"
    t.index ["user_id", "occurred_at"], name: "index_activities_on_user_id_and_occurred_at"
    t.index ["user_id"], name: "index_activities_on_user_id"
  end

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "company_settings", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.boolean "activity_tracking"
    t.integer "activity_retention_days"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_company_settings_on_company_id"
  end

  create_table "company_user_roles", force: :cascade do |t|
    t.bigint "company_user_id", null: false
    t.bigint "role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_user_id"], name: "index_company_user_roles_on_company_user_id"
    t.index ["role_id"], name: "index_company_user_roles_on_role_id"
  end

  create_table "company_users", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.bigint "user_id", null: false
    t.datetime "joined_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "current_role_id"
    t.index ["company_id"], name: "index_company_users_on_company_id"
    t.index ["current_role_id"], name: "index_company_users_on_current_role_id"
    t.index ["user_id"], name: "index_company_users_on_user_id"
  end

  create_table "recognitions", force: :cascade do |t|
    t.integer "giver_id", null: false
    t.integer "recipient_id", null: false
    t.bigint "company_id", null: false
    t.integer "points", null: false
    t.text "message", null: false
    t.string "category", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_recognitions_on_category"
    t.index ["company_id", "created_at"], name: "index_recognitions_on_company_id_and_created_at"
    t.index ["company_id"], name: "index_recognitions_on_company_id"
    t.index ["giver_id", "created_at"], name: "index_recognitions_on_giver_id_and_created_at"
    t.index ["giver_id"], name: "index_recognitions_on_giver_id"
    t.index ["recipient_id", "created_at"], name: "index_recognitions_on_recipient_id_and_created_at"
    t.index ["recipient_id"], name: "index_recognitions_on_recipient_id"
    t.index ["status"], name: "index_recognitions_on_status"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.jsonb "permissions"
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_roles_on_company_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "full_name"
    t.integer "selected_company_id"
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_users_on_discarded_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "activities", "companies"
  add_foreign_key "activities", "users"
  add_foreign_key "company_settings", "companies"
  add_foreign_key "company_user_roles", "company_users"
  add_foreign_key "company_user_roles", "roles"
  add_foreign_key "company_users", "companies"
  add_foreign_key "company_users", "roles", column: "current_role_id"
  add_foreign_key "company_users", "users"
  add_foreign_key "recognitions", "companies"
  add_foreign_key "recognitions", "users", column: "giver_id"
  add_foreign_key "recognitions", "users", column: "recipient_id"
  add_foreign_key "roles", "companies"
end
