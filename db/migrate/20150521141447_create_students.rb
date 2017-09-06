class CreateStudents < ActiveRecord::Migration[5.1]
  def change
    create_table :students do |t|
      t.string :name
      t.string :email      
      t.string :phoneNumber, unique: true

      t.timestamps null: true
    end
  end
end
