class AddRemark1ToStudents < ActiveRecord::Migration[5.1]
  def change
    add_column :students, :remark1, :string
  end
end
