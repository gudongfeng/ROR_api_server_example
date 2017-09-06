class AddStudentReferencesToAppointments < ActiveRecord::Migration[5.1]
  def change
    add_reference :appointments, :student, index: true
    add_foreign_key :appointments, :students
  end
end
