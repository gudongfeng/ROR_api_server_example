class AddTutorFeedbackToAppointment < ActiveRecord::Migration[5.1]
  def change
    add_column :appointments, :tutor_feedback, :text
  end
end
