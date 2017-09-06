class ChangeRelationBetweenNewsTopics < ActiveRecord::Migration[5.1]
  def change
    create_table :core_news_core_topics, id:false do |t|
      t.belongs_to :core_new, index:true
      t.belongs_to :core_topic, index:true
    end
  end
end
