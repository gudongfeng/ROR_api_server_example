class AddActivationToTutors < ActiveRecord::Migration[5.1]
  def change
    add_column :tutors, :activation_digest, :string
    add_column :tutors, :activated, :boolean, default: false
    add_column :tutors, :activated_at, :datetime
  end
end
