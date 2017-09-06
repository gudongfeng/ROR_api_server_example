class CreateEducations < ActiveRecord::Migration[5.1]
  def change
    create_table :educations do |t|
      t.string :school
      t.string :major
      t.string :degree
      t.date :start_time
      t.date :end_time

      t.timestamps null: false
    end
  end
end
