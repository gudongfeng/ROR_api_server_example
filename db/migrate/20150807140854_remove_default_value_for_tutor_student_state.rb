class RemoveDefaultValueForTutorStudentState < ActiveRecord::Migration[5.1]
  def change
    change_column_default :tutors, :state, nil
    change_column_default :students, :state, nil
  end
end
