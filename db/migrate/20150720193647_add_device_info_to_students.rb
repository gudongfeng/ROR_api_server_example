class AddDeviceInfoToStudents < ActiveRecord::Migration[5.1]
  def change
    add_column :students, :device_token, :string
    add_column :students, :device_type, :string
  end
end
