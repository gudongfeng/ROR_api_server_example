class AddPhoneNumberToTutor < ActiveRecord::Migration[5.1]
  def change
    add_column :tutors, :phoneNumber, :string
  end
end
