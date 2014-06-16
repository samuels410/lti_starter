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

ActiveRecord::Schema.define(:version => 20140614100046) do

  create_table "account_transactions", :force => true do |t|
    t.integer  "subscription_id", :null => false
    t.boolean  "success",         :null => false
    t.string   "billing_key",     :null => false
    t.integer  "amount_paisa",    :null => false
    t.string   "message"
    t.datetime "created_at",      :null => false
  end

  add_index "account_transactions", ["subscription_id"], :name => "index_account_transactions_on_subscription_id"

  create_table "billing_types", :force => true do |t|
    t.integer  "organization_id"
    t.string   "billing_type"
    t.decimal  "discount_percentage"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.integer  "months"
  end

  create_table "domains", :force => true do |t|
    t.string   "host"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "external_configs", :force => true do |t|
    t.string   "config_type"
    t.string   "app_name"
    t.integer  "organization_id"
    t.text     "value"
    t.text     "shared_secret"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "feature_sets", :force => true do |t|
    t.integer "organization_id",                    :null => false
    t.string  "name"
    t.integer "no_students"
    t.integer "no_teachers"
    t.integer "no_admins"
    t.integer "no_courses"
    t.integer "storage"
    t.boolean "unlimited",       :default => false
  end

  create_table "organizations", :force => true do |t|
    t.string   "host"
    t.string   "name"
    t.text     "url"
    t.string   "description"
    t.string   "image"
    t.string   "email"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "payments", :force => true do |t|
    t.integer  "subscription_id"
    t.integer  "user_config_id"
    t.integer  "subscription_plan_id"
    t.text     "merchant_transaction_id"
    t.text     "final_redirect_url"
    t.decimal  "transaction_amount"
    t.string   "buyer_email_address"
    t.string   "transaction_type"
    t.string   "payment_method"
    t.string   "currency"
    t.string   "ui_mode"
    t.string   "hash_method"
    t.boolean  "completed",               :default => false
    t.boolean  "canceled",                :default => false
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.string   "bank_name"
    t.integer  "billing_type_id"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "roles", ["name", "resource_type", "resource_id"], :name => "index_roles_on_name_and_resource_type_and_resource_id"
  add_index "roles", ["name"], :name => "index_roles_on_name"

  create_table "subscription_changes", :force => true do |t|
    t.integer  "subscribable_id",               :null => false
    t.string   "subscribable_type",             :null => false
    t.integer  "original_subscription_plan_id"
    t.integer  "new_subscription_plan_id"
    t.string   "reason",                        :null => false
    t.datetime "created_at",                    :null => false
  end

  add_index "subscription_changes", ["reason"], :name => "index_subscription_changes_on_reason"
  add_index "subscription_changes", ["subscribable_id", "subscribable_type"], :name => "on_subscribable_id_and_type"

  create_table "subscription_plans", :force => true do |t|
    t.integer "organization_id", :null => false
    t.string  "name",            :null => false
    t.string  "redemption_key"
    t.integer "rate_cents",      :null => false
    t.string  "feature_set_id",  :null => false
  end

  create_table "subscriptions", :force => true do |t|
    t.integer  "organization_id",                         :null => false
    t.integer  "subscribable_id",                         :null => false
    t.string   "subscribable_type",                       :null => false
    t.string   "billing_key"
    t.integer  "subscription_plan_id",                    :null => false
    t.date     "paid_through"
    t.date     "expire_on"
    t.date     "started_on"
    t.datetime "last_transaction_at"
    t.boolean  "in_trial",             :default => false, :null => false
  end

  add_index "subscriptions", ["billing_key"], :name => "index_subscriptions_on_billing_key"
  add_index "subscriptions", ["expire_on"], :name => "index_subscriptions_on_expire_on"
  add_index "subscriptions", ["paid_through"], :name => "index_subscriptions_on_paid_through"
  add_index "subscriptions", ["subscribable_id"], :name => "index_subscriptions_on_subscribable_id"
  add_index "subscriptions", ["subscribable_type"], :name => "index_subscriptions_on_subscribable_type"

  create_table "user_configs", :force => true do |t|
    t.integer  "user_id"
    t.text     "access_token"
    t.integer  "domain_id"
    t.string   "name"
    t.text     "image"
    t.string   "global_user_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "name",                   :default => "unknown"
    t.string   "email",                  :default => "",        :null => false
    t.string   "encrypted_password",     :default => "",        :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0,         :null => false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "users_roles", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], :name => "index_users_roles_on_user_id_and_role_id"

end
