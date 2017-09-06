class CreateRequests < ActiveRecord::Migration[5.1]
  def change
    create_table :requests do |t|
      t.string :tutor_reply

      t.timestamps null: false
    end
  end
end
