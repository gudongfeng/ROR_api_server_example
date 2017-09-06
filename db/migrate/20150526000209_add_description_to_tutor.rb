class AddDescriptionToTutor < ActiveRecord::Migration[5.1]
  def change
    add_column :tutors, :description, :text
  end
end
