class AddDicountChineseStringToDiscounts < ActiveRecord::Migration[5.1]
  def change
    add_column :discounts, :discount_rate_chinese, :string
  end
end
