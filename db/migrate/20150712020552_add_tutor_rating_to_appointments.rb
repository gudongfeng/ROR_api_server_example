class AddTutorRatingToAppointments < ActiveRecord::Migration[5.1]
  def change
    add_column :appointments, :tutor_rating, :string
  end
end
