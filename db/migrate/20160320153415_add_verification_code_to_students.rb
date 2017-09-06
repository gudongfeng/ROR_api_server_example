class AddVerificationCodeToStudents < ActiveRecord::Migration[5.1]
  def change
    add_column :students, :verification_code, :string
  end
end
