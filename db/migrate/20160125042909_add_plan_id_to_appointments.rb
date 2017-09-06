class AddPlanIdToAppointments < ActiveRecord::Migration[5.1]
  def change
    add_column :appointments, :plan_id, :integer
  end
end
