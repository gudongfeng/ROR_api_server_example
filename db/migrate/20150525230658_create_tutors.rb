class CreateTutors < ActiveRecord::Migration[5.1]
  def change
    create_table :tutors do |t|
      t.string :name
      t.string :email
      t.string :password_digest
      t.string :remember_token
      t.date :remember_expiry
      t.string :country
      t.string :picture
      t.string :region

      t.timestamps null: true
    end
  end
end
