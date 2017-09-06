class RemoveTypeFromTransaction < ActiveRecord::Migration[5.1]
  def change
    remove_column :transactions, :type, :string
  end
end
