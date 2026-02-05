class CreateAuditLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :audit_logs do |t|
      t.string :subject_type
      t.integer :subject_id
      t.string :event
      t.text :details

      t.timestamps
    end
  end
end
