class RemoveStateFromTutor < ActiveRecord::Migration[5.1]
  def change
    remove_column :tutors, :state
  end
end
