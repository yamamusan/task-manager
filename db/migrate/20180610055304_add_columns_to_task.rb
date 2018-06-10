class AddColumnsToTask < ActiveRecord::Migration[5.2]
  def change
    change_column :tasks, :title, :string, null: false
    add_column :tasks, :priority, :integer
    add_column :tasks, :status, :integer, default: 0, null: false
    add_column :tasks, :due_date, :date
  end
end
