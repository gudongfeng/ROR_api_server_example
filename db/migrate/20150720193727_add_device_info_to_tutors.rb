class AddDeviceInfoToTutors < ActiveRecord::Migration[5.1]
  def change
    add_column :tutors, :device_token, :string
    add_column :tutors, :device_type, :string
  end
end
