class AddAppointmentRefToFees < ActiveRecord::Migration[5.1]
  def change
    add_reference :fees, :appointment, index: true
    add_foreign_key :fees, :appointments
  end
end
