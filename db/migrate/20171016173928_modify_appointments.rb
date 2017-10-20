class ModifyAppointments < ActiveRecord::Migration[5.1]
  def change
    remove_column :appointments, :order_no
    remove_column :appointments, :student_call_uuid
    remove_column :appointments, :tutor_call_uuid
    remove_column :appointments, :student_sidekiq_job_id
    remove_column :appointments, :tutor_sidekiq_job_id
    remove_column :appointments, :hard_worker
    remove_column :appointments, :call_hangup
    add_column :appointments, :complete_call_jid, :string
  end
end
