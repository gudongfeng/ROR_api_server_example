class AddFavourTopicIdsToTutor < ActiveRecord::Migration[5.1]
  def change
    add_column :tutors, :favour_topic_ids, :string
  end
end
