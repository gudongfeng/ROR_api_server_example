class AddDiscountReferenceToAppointmnets < ActiveRecord::Migration[5.1]
  def change
    add_reference :appointments, :discount, index: true
    add_foreign_key :appointments, :discounts
  end
end
