class AddStudentRefToRequests < ActiveRecord::Migration[5.1]
  def change
    add_reference :requests, :student, index: true
    add_foreign_key :requests, :students
  end
end
