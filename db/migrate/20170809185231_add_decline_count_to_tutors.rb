class AddDeclineCountToTutors < ActiveRecord::Migration[5.1]
  def change
    add_column :tutors, :decline_count, :integer
  end
end
