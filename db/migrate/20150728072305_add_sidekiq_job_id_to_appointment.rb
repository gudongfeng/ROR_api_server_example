class AddSidekiqJobIdToAppointment < ActiveRecord::Migration[5.1]
  def change
    add_column :appointments, :student_sidekiq_job_id, :string
    add_column :appointments, :tutor_sidekiq_job_id, :string
  end
end
