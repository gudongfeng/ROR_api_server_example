class AddStudentReferencesToTransactions < ActiveRecord::Migration[5.1]
  def change
    add_reference :transactions, :student, index: true
    add_foreign_key :transactions, :students
  end
end
