class AddTutorReferencesToEducations < ActiveRecord::Migration[5.1]
  def change
    add_reference :educations, :tutor, index: true
    add_foreign_key :educations, :tutors
  end
end
