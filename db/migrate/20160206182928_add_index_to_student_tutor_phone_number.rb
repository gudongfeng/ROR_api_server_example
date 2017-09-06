class AddIndexToStudentTutorPhoneNumber < ActiveRecord::Migration[5.1]
  def change
    add_index :tutors, :phoneNumber, unique: true
    add_index :students, :phoneNumber, unique: true
  end
end
