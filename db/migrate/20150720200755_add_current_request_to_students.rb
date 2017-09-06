class AddCurrentRequestToStudents < ActiveRecord::Migration[5.1]
  def change
    add_column :students, :current_request, :integer
  end
end
