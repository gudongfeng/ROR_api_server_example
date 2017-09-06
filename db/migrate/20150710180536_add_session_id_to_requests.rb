class AddSessionIdToRequests < ActiveRecord::Migration[5.1]
  def change
    add_column :requests, :session_id, :integer
  end
end
