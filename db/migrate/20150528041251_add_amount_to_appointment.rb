class AddAmountToAppointment < ActiveRecord::Migration[5.1]
  def change
    add_column :appointments, :amount, :decimal, precision: 8, scale: 2
  end
end
