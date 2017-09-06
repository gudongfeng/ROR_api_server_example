class AddStateToTutors < ActiveRecord::Migration[5.1]
  def change
    add_column :tutors, :state, :string, default: "unavailable"
  end
end
