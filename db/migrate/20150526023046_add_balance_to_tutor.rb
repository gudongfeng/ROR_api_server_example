class AddBalanceToTutor < ActiveRecord::Migration[5.1]
  def change
    add_column :tutors, :balance, :decimal, precision: 8, scale: 2
  end
end
