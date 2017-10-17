class RemoveCallDurationInAppointments < ActiveRecord::Migration[5.1]
  def change
    remove_column :appointments, :student_call_duration
    remove_column :appointments, :tutor_call_duration
  end
end
