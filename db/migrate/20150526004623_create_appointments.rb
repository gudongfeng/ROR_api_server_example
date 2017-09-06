class CreateAppointments < ActiveRecord::Migration[5.1]
  def change
    create_table :appointments do |t|
      t.string :state
      t.datetime :state_start_time
      t.datetime :start_time
      t.datetime :end_time
      t.decimal :fee, precision: 8, scale: 2

      t.timestamps null: false
    end
  end
end
