class AddCountryCodeToStudents < ActiveRecord::Migration[5.1]
  def change
    add_column :students, :country_code, :integer
  end
end
