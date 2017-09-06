class AddAppointmentIdToRequest < ActiveRecord::Migration[5.1]
  def change
    add_column :requests, :appointment_id, :integer
  end
end
