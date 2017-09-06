class ChangeTopicNewsName < ActiveRecord::Migration[5.1]
  def change
    rename_table :core_topics, :topics
    rename_table :core_news, :news
    rename_column :requests, :core_topic_id, :topic_id
    rename_table :core_news_core_topics, :news_topics
    change_table :news_topics, id:false do |t|
      t.belongs_to :new, index:true
      t.belongs_to :topic, index:true
    end
  end
end
