class RemoveStatusFromStudents < ActiveRecord::Migration[5.0]
  def change
    remove_column :students, :status
  end
end
