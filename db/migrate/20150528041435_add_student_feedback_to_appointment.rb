class AddStudentFeedbackToAppointment < ActiveRecord::Migration[5.1]
  def change
    add_column :appointments, :student_feedback, :text
  end
end
