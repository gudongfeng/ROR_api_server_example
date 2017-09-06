class RemoveRealPictureFromStudents < ActiveRecord::Migration[5.0]
  def change
    remove_column :students, :real_picture
    add_column :students, :gender, :string
  end
end
