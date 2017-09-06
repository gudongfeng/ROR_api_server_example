class DropTableRequest < ActiveRecord::Migration[5.1]
  def change
    drop_table :requests
  end
end
