class RemoveFavourTopicIdsFromTutor < ActiveRecord::Migration[5.0]
  def change
    remove_column :tutors, :favour_topic_ids, :string
  end
end
