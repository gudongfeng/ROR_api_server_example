class DropTopic < ActiveRecord::Migration[5.1]
  def change
    drop_table :topics
    drop_table :news_topics
    drop_table :news
    drop_table :fees
    drop_table :works
  end
end
