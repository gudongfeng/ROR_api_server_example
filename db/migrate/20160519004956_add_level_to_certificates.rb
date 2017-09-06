class AddLevelToCertificates < ActiveRecord::Migration[5.1]
  def change
    add_column :certificates, :level, :integer
    add_column :certificates, :requirement_num, :integer
  end
end
