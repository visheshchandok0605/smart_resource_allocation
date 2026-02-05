class CreateResourceBookings < ActiveRecord::Migration[8.1]
  def change
    create_table :resource_bookings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :office_resource, null: false, foreign_key: true
      t.datetime :start_time
      t.datetime :end_time
      t.integer :status
      t.text :admin_note

      t.timestamps
    end
  end
end
