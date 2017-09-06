class AddTutorReferencesToAppointments < ActiveRecord::Migration[5.1]
  def change
    add_reference :appointments, :tutor, index: true
    add_foreign_key :appointments, :tutors
  end
end
