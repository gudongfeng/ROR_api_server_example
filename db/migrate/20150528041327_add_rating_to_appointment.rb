class AddRatingToAppointment < ActiveRecord::Migration[5.1]
  def change
    add_column :appointments, :rating, :integer
  end
end
