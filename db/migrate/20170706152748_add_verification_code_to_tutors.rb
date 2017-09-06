class AddVerificationCodeToTutors < ActiveRecord::Migration[5.1]
  def change
    add_column :tutors, :verification_code, :string
  end
end
