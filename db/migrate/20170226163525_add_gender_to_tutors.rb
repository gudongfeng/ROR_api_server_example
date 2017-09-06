class AddGenderToTutors < ActiveRecord::Migration[5.0]
  def change
    add_column :tutors, :gender, :string
  end
end
