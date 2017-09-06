class CreateCoreDiscounts < ActiveRecord::Migration[5.1]
  def change
    create_table :discounts do |t|
      t.string :value
      t.integer :count
      t.string :company_logo

      t.timestamps null: false
    end
  end
end
