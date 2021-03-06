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

ActiveRecord::Schema.define(version: 20_151_221_145_439) do
  create_table 'contact_notes_logs', force: :cascade do |t|
    t.integer 'contact_id', null: false
    t.date 'recorded_on', null: false
    t.string 'notes'
    t.datetime 'created_at',  null: false
    t.datetime 'updated_at',  null: false
  end

  create_table 'contacts', force: :cascade do |t|
    t.string 'name'
    t.string 'status'
    t.decimal 'pledge_amount'
    t.text 'notes'
    t.datetime 'created_at',    null: false
    t.datetime 'updated_at',    null: false
  end

  create_table 'partner_status_logs', force: :cascade do |t|
    t.integer 'contact_id', null: false
    t.date 'recorded_on', null: false
    t.string 'status'
    t.decimal 'pledge_amount'
    t.datetime 'created_at',    null: false
    t.datetime 'updated_at',    null: false
  end

  add_index 'partner_status_logs', ['contact_id'], name: 'index_partner_status_logs_on_contact_id'
  add_index 'partner_status_logs', ['recorded_on'], name: 'index_partner_status_logs_on_recorded_on'
end
