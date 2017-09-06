class AddTutorEarnedToAppointments < ActiveRecord::Migration[5.1]
  def change
    add_column :appointments, :tutor_earned, :decimal, precision: 8, scale: 2
  end
end
