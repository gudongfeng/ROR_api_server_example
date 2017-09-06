class RemoveRealPictureFromTutors < ActiveRecord::Migration[5.0]
  def change
    remove_column :tutors, :real_picture
  end
end
