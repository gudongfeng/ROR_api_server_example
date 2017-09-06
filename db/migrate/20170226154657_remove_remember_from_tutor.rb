class RemoveRememberFromTutor < ActiveRecord::Migration[5.0]
  def change
    remove_column :tutors, :remember_token
    remove_column :tutors, :remember_expiry
  end
end
