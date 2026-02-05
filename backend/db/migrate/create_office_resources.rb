class CreateOfficeResources < ActiveRecord::Migration[8.1]
  def change
    create_table :office_resources do |t|
      t.string :name
      t.integer :resource_type
      t.jsonb :configuration
      t.integer :status

      t.timestamps
    end
  end
end
