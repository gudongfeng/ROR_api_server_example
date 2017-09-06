class AddRemark1ToRequests < ActiveRecord::Migration[5.1]
  def change
    add_column :requests, :remark1, :string
  end
end
