class AddTutorReferencesToTransactions < ActiveRecord::Migration[5.1]
  def change
    add_reference :transactions, :tutor, index: true
    add_foreign_key :transactions, :tutors
  end
end
