class AddCallSpeakReminderToAppointments < ActiveRecord::Migration[5.1]
  def change
    add_column :appointments, :hard_worker, :string
    add_column :appointments, :call_hangup, :string
  end
end
