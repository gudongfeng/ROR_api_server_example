class AddResetToTutors < ActiveRecord::Migration[5.1]
  def change
    add_column :tutors, :reset_digest, :string
    add_column :tutors, :reset_sent_at, :datetime
  end
end
