class UpdateTutorRatingAppointments < ActiveRecord::Migration[5.1]
  def change
    change_column :appointments, :tutor_rating, 'integer USING CAST(tutor_rating AS integer)'
  end
end
