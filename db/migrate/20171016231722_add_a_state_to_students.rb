class AddAStateToStudents < ActiveRecord::Migration[5.1]
  def change
    add_column :students, :state, :string
    remove_column :students, :reset_digest
    remove_column :students, :reset_sent_at
    remove_column :tutors, :reset_digest
    remove_column :tutors, :reset_sent_at
    remove_column :tutors, :activation_digest
  end
end
