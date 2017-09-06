class AddOriginPictureUrlToCertificates < ActiveRecord::Migration[5.1]
  def change
    add_column :certificates, :origin_picture_url, :string
  end
end
