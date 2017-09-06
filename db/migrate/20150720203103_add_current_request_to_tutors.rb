class AddCurrentRequestToTutors < ActiveRecord::Migration[5.1]
  def change
    add_column :tutors, :current_request, :integer
  end
end
