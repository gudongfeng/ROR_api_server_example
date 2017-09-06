class CreateCoreVersions < ActiveRecord::Migration[5.1]
  def change
    create_table :versions do |t|
      t.string :name
      t.string :app_type
      t.boolean :force_update
      t.timestamps null: false
    end
  end
end
