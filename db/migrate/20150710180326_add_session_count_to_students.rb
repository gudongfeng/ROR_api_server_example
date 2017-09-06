class AddSessionCountToStudents < ActiveRecord::Migration[5.1]
  def change
    add_column :students, :session_count, :integer, :default => 1
  end
end
