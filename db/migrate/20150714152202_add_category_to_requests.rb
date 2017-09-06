class AddCategoryToRequests < ActiveRecord::Migration[5.1]
  def change
    add_column :requests, :category, :string, :default => 'regular'
  end
end
