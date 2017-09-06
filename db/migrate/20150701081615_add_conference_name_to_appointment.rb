class AddConferenceNameToAppointment < ActiveRecord::Migration[5.1]
  def change
    add_column :appointments, :conference_name, :string
  end
end
