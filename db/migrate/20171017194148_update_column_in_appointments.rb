class UpdateColumnInAppointments < ActiveRecord::Migration[5.1]
  def change
    rename_column :appointments, :complete_call_jid, :jids
  end
end
