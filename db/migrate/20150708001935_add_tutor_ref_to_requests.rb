class AddTutorRefToRequests < ActiveRecord::Migration[5.1]
  def change
    add_reference :requests, :tutor, index: true
    add_foreign_key :requests, :tutors
  end
end
