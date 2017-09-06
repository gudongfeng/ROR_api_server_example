class AddCountryCodeToTutors < ActiveRecord::Migration[5.0]
  def change
    add_column :tutors, :country_code, :integer
  end
end
