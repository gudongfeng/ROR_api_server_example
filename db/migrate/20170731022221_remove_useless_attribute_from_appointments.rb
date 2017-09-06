class RemoveUselessAttributeFromAppointments < ActiveRecord::Migration[5.1]
  def change
    remove_column :appointments, :state
    remove_column :appointments, :state_start_time
    remove_column :appointments, :fee
    remove_column :appointments, :amount
  end
end
