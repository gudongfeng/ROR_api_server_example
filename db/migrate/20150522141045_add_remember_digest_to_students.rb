class AddRememberDigestToStudents < ActiveRecord::Migration[5.1]
  def change
    add_column :students, :remember_token, :string
    add_column :students, :remember_expiry, :datetime
  end
end
