class UpdateRequest < ActiveRecord::Migration[5.1]
  def change
    remove_column :requests, :topic_id
    remove_column :requests, :remark1
    remove_column :requests, :session_id
    remove_column :requests, :plan_id
  end
end
