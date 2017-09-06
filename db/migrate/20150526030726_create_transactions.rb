class CreateTransactions < ActiveRecord::Migration[5.1]
  def change
    create_table :transactions do |t|
      t.decimal :amount, precision: 8, scale: 2
      t.string :type
      t.string :state

      t.timestamps null: false
    end
  end
end
