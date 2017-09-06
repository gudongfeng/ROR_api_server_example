class AddIndexToTutors < ActiveRecord::Migration[5.1]
  def change
  	add_index :tutors, :remember_token, unique: true
    add_index :tutors, :email, unique: true
  end
end
