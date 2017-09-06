class AddIndexToRememberDigest < ActiveRecord::Migration[5.1]
  def change
    add_index :students, :remember_token, unique: true
  end
end
