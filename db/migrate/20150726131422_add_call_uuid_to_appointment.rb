class AddCallUuidToAppointment < ActiveRecord::Migration[5.1]
  def change
    add_column :appointments, :student_call_uuid, :string
    add_column :appointments, :tutor_call_uuid, :string
  end
end
