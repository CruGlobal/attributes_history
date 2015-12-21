class CreateContactNotesLog < ActiveRecord::Migration
  def change
    create_table :contact_notes_logs do |t|
      t.integer :contact_id, null: false
      t.date :recorded_on, null: false

      t.string :notes

      t.timestamps null: false
    end
  end
end
