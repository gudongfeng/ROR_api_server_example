class AddLevelToTutors < ActiveRecord::Migration[5.1]
  def change
    add_column :tutors, :level, :integer
  end
end
