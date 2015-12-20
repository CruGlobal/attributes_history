class CreatePartnerStatusLogs < ActiveRecord::Migration
  def change
    create_table :partner_status_logs do |t|
      t.integer :contact_id, null: false
      t.date :versioned_on, null: false
      t.string :status
      t.decimal :pledge_amount

      t.timestamps null: false
    end
  end
end
