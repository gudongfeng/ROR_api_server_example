class AddBalanceToStudent < ActiveRecord::Migration[5.1]
  def change
    add_column :students, :balance, :decimal, precision: 8, scale: 2
  end
end
