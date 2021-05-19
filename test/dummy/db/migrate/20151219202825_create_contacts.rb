# frozen_string_literal: true

class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.string :name
      t.string :status
      t.decimal :pledge_amount
      t.text :notes

      t.timestamps null: false
    end
  end
end
