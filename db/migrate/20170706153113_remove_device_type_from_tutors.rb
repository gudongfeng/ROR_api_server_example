class RemoveDeviceTypeFromTutors < ActiveRecord::Migration[5.1]
  def change
    remove_column :tutors, :device_type
  end
end
