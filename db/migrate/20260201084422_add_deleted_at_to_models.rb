class AddDeletedAtToModels < ActiveRecord::Migration[8.1]
  def change
    add_column :office_resources, :deleted_at, :datetime
    add_index :office_resources, :deleted_at
    add_column :resource_bookings, :deleted_at, :datetime
    add_index :resource_bookings, :deleted_at
  end
end
