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

ActiveRecord::Schema.define(version: 20141125201454) do

  create_table "registrations", force: true do |t|
    t.string   "title"
    t.string   "firstName"
    t.string   "lastName"
    t.string   "email"
    t.string   "institutionalAffiliation"
    t.string   "accommodationType"
    t.string   "doubleRoomShare"
    t.integer  "accompaniedBy"
    t.boolean  "presentationPoster"
    t.boolean  "presentationOral"
    t.date     "extraNightsBefoe"
    t.date     "extraNightsAfter"
    t.text     "specialRequests",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "passport"
    t.string   "country"
    t.string   "citizenship"
    t.string   "spouse_name"
    t.string   "spouse_passport"
    t.string   "spouse_country"
    t.string   "twin_share_with"
    t.string   "jerusalem_tour"
    t.string   "deadsea_tour"
    t.string   "nazareth_tour"
    t.string   "caesarea"
    t.integer  "jerusalem_participants"
    t.integer  "deadsea_participants"
    t.integer  "nazareth_participants"
    t.integer  "caesarea_participants"
    t.string   "PrimaType"
    t.string   "PrimaSpouse"
    t.string   "PrimaSpousePassport"
    t.string   "PrimaSpouseCountry"
    t.boolean  "payed"
    t.string   "credit2000Approve"
    t.boolean  "June22"
    t.boolean  "June23"
    t.boolean  "June24"
    t.boolean  "June25"
    t.string   "PaymentMethod"
  end

  add_index "registrations", ["email"], name: "index_registrations_on_email", unique: true

  create_table "users", force: true do |t|
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
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
