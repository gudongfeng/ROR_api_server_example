class AddTutorIdToStudents < ActiveRecord::Migration[5.1]
  def change
    add_column :students, :prioritized_tutor, :integer
  end
end
