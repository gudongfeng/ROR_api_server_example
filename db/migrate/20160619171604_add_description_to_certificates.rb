class AddDescriptionToCertificates < ActiveRecord::Migration[5.1]
  def change
    add_column :certificates, :description, :text
  end
end
