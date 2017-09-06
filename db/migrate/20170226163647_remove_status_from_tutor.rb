class RemoveStatusFromTutor < ActiveRecord::Migration[5.0]
  def change
    remove_column :tutors, :status, :string
  end
end
