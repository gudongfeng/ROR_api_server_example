class AddPictureToStudent < ActiveRecord::Migration[5.1]
  def change
    add_column :students, :picture, :string
  end
end
