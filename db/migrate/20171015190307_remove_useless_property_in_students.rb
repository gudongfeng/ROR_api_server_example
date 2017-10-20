class RemoveUselessPropertyInStudents < ActiveRecord::Migration[5.1]
  def change
    remove_column :students, :prioritized_tutor
    remove_column :students, :state
    remove_column :students, :remark1
    remove_column :students, :current_request
    remove_column :tutors,   :current_request
    remove_column :tutors,   :tutor_timer_job_id
  end
end
