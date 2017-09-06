class RemoveRemeberFromStudents < ActiveRecord::Migration[5.0]
  def change
    remove_column :students, :remember_token
    remove_column :students, :remember_expiry
  end
end
