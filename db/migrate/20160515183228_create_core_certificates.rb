class CreateCoreCertificates < ActiveRecord::Migration[5.1]
  def change
    create_table :certificates do |t|
      t.string :name
      t.string :picture_url

      t.timestamps null: false
    end
  end
end
