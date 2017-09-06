class AddOrderNoToAppointment < ActiveRecord::Migration[5.1]
  def change
    add_column :appointments, :order_no, :string
    add_index :appointments, :order_no, unique: true
  end
end
