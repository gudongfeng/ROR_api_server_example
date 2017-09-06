class RemoveActivationDigestFromStudents < ActiveRecord::Migration[5.0]
  def change
    remove_column :students, :activation_digest
  end
end
