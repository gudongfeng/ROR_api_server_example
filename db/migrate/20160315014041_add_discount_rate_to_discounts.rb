class AddDiscountRateToDiscounts < ActiveRecord::Migration[5.1]
  def change
    add_column :discounts, :rate, :float
  end
end
