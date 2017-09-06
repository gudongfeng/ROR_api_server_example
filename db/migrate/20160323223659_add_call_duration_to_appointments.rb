class AddCallDurationToAppointments < ActiveRecord::Migration[5.1]
  def change
    add_column :appointments, :student_call_duration, :integer
    add_column :appointments, :tutor_call_duration, :integer
  end
end
