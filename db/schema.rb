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

ActiveRecord::Schema.define(version: 2020_08_10_013345) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "admins", force: :cascade do |t|
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "name"
    t.string "email"
    t.json "tokens"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_admins_on_uid_and_provider", unique: true
  end

  create_table "cancellations", force: :cascade do |t|
    t.string "description"
    t.bigint "service_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "response"
    t.index ["service_id"], name: "index_cancellations_on_service_id"
  end

  create_table "capacities", force: :cascade do |t|
    t.bigint "worker_id"
    t.bigint "sub_category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sub_category_id"], name: "index_capacities_on_sub_category_id"
    t.index ["worker_id"], name: "index_capacities_on_worker_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "title"
    t.string "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "clients", force: :cascade do |t|
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "name"
    t.string "image"
    t.string "email"
    t.json "tokens"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "approved", default: false
    t.string "register_token"
    t.string "image_path"
    t.string "document_path"
    t.string "proof_of_address_path"
    t.string "criminal_path"
    t.string "cpf"
    t.string "confirmation_token"
    t.string "status", default: "pending", null: false
    t.string "reject_reason"
    t.boolean "allow_password_change", default: false
    t.boolean "password_will_change", default: false
    t.string "phone"
    t.decimal "rate", default: "5.0"
    t.string "registration_id"
    t.boolean "blocked", default: false
    t.string "wirecard_id"
    t.string "bio"
    t.string "document_verse_path"
    t.boolean "phone_validated", default: false
    t.index ["cpf"], name: "index_clients_on_cpf", unique: true
    t.index ["email"], name: "index_clients_on_email", unique: true
    t.index ["reset_password_token"], name: "index_clients_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_clients_on_uid_and_provider", unique: true
  end

  create_table "cupon_usages", force: :cascade do |t|
    t.bigint "service_id"
    t.bigint "client_id"
    t.bigint "cupon_id"
    t.index ["client_id"], name: "index_cupon_usages_on_client_id"
    t.index ["cupon_id"], name: "index_cupon_usages_on_cupon_id"
    t.index ["service_id"], name: "index_cupon_usages_on_service_id"
  end

  create_table "cupons", force: :cascade do |t|
    t.string "name"
    t.decimal "percentage"
  end

  create_table "documents", force: :cascade do |t|
    t.string "name"
    t.string "status", default: "waiting_for_acceptance"
    t.string "reject_reason"
    t.bigint "client_id"
    t.bigint "worker_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_documents_on_client_id"
    t.index ["worker_id"], name: "index_documents_on_worker_id"
  end

  create_table "evaluations", force: :cascade do |t|
    t.integer "rate"
    t.bigint "service_id"
    t.bigint "client_id"
    t.bigint "worker_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_evaluations_on_client_id"
    t.index ["service_id"], name: "index_evaluations_on_service_id"
    t.index ["worker_id"], name: "index_evaluations_on_worker_id"
  end

  create_table "problems", force: :cascade do |t|
    t.string "description"
    t.bigint "service_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "response"
    t.index ["service_id"], name: "index_problems_on_service_id"
  end

  create_table "proposals", force: :cascade do |t|
    t.decimal "price", precision: 7, scale: 2
    t.string "text"
    t.bigint "service_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "worker_id"
    t.string "status", default: "waiting_for_approval"
    t.string "reject_reason"
    t.index ["service_id"], name: "index_proposals_on_service_id"
    t.index ["worker_id"], name: "index_proposals_on_worker_id"
  end

  create_table "services", force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.datetime "end_date"
    t.boolean "material_support", default: false
    t.string "status", default: "waiting_for_approval"
    t.boolean "approved", default: false
    t.bigint "client_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "address"
    t.datetime "start_date"
    t.string "reject_reason"
    t.string "start_time"
    t.string "end_time"
    t.json "images", default: [], array: true
    t.bigint "worker_id"
    t.json "charges", default: [], array: true
    t.boolean "notified_approved_payment", default: false
    t.index ["client_id"], name: "index_services_on_client_id"
    t.index ["worker_id"], name: "index_services_on_worker_id"
  end

  create_table "services_sub_categories", id: false, force: :cascade do |t|
    t.bigint "service_id"
    t.bigint "sub_category_id"
    t.index ["service_id"], name: "index_services_sub_categories_on_service_id"
    t.index ["sub_category_id"], name: "index_services_sub_categories_on_sub_category_id"
  end

  create_table "sub_categories", force: :cascade do |t|
    t.string "title"
    t.string "image"
    t.bigint "category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_sub_categories_on_category_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.string "order_status", default: "0"
    t.string "order_id"
    t.bigint "service_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "payment_status", default: "CREATED"
    t.string "payment_id"
    t.index ["service_id"], name: "index_transactions_on_service_id"
  end

  create_table "workers", force: :cascade do |t|
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "name"
    t.string "image"
    t.string "email"
    t.json "tokens"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "approved", default: false
    t.string "register_token"
    t.string "confirmation_token"
    t.string "image_path"
    t.string "document_path"
    t.string "proof_of_address_path"
    t.string "criminal_path"
    t.string "status", default: "pending", null: false
    t.string "cpf"
    t.string "reject_reason"
    t.json "address", default: {}
    t.boolean "allow_password_change", default: false
    t.boolean "password_will_change", default: false
    t.string "phone"
    t.decimal "rate", default: "5.0"
    t.string "registration_id"
    t.boolean "blocked", default: false
    t.string "bio"
    t.string "document_verse_path"
    t.string "bank_digit"
    t.string "bank_account"
    t.string "bank_agency"
    t.string "bank_account_type"
    t.index ["cpf"], name: "index_workers_on_cpf", unique: true
    t.index ["email"], name: "index_workers_on_email", unique: true
    t.index ["reset_password_token"], name: "index_workers_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_workers_on_uid_and_provider", unique: true
  end

  add_foreign_key "documents", "clients"
  add_foreign_key "documents", "workers"
  add_foreign_key "services", "workers"
end
