class AddPayStateToAppointment < ActiveRecord::Migration[5.1]
  def change
    add_column :appointments, :pay_state, :string, default: "unpaid"
  end
end
