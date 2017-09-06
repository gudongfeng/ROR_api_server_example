class CreateCoreTopics < ActiveRecord::Migration[5.1]
  def change
    create_table :core_topics do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
