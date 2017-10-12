class ChangeImageAdminType < ActiveRecord::Migration[5.0]
  def change
    add_column :parcels, :images, :json
    remove_column :parcels, :image_admin, :string
  end
end
