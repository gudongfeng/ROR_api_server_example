class AddStatusToTutors < ActiveRecord::Migration[5.1]
  def change
    add_column :tutors, :status, :string
  end
end
