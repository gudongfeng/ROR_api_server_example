class AddRealPictureToStudent < ActiveRecord::Migration[5.1]
  def change
    add_column :students, :real_picture, :string
  end
end
