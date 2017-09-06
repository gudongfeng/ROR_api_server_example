class CreateWorks < ActiveRecord::Migration[5.1]
  def change
    create_table :works do |t|
      t.string :company
      t.string :position
      t.date :start_time
      t.date :end_time

      t.timestamps null: false
    end
  end
end
