class AddTopicIdToRequest < ActiveRecord::Migration[5.1]
  def change
    add_column :requests, :core_topic_id, :integer
  end
end
