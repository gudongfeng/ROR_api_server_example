class CreateFees < ActiveRecord::Migration[5.1]
  def change
    create_table :fees do |t|
      t.decimal :tutor_fee, precision: 8, scale: 2
      t.string :calling_fee, precision: 8, scale: 2
      t.string :punishment_fee, precision: 8, scale: 2

      t.timestamps null: false
    end
  end
end
