class AddTutorReferencesToWorks < ActiveRecord::Migration[5.1]
  def change
    add_reference :works, :tutor, index: true
    add_foreign_key :works, :tutors
  end
end
