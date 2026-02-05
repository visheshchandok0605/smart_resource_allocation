class AddEmployeeIdToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :employee_id, :string
    add_index :users, :employee_id
  end
end
