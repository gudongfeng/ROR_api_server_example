class AddRealPictureToTutor < ActiveRecord::Migration[5.1]
  def change
    add_column :tutors, :real_picture, :string
  end
end
