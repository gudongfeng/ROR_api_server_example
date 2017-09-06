class AddTutorTimerJobIdToTutor < ActiveRecord::Migration[5.1]
  def change
    add_column :tutors, :tutor_timer_job_id, :string
  end
end
