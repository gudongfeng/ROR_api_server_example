class AddSourceToTransaction < ActiveRecord::Migration[5.1]
  def change
    add_column :transactions, :source, :string
  end
end
