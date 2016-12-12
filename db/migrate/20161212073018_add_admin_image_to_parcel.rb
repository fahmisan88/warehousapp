class AddAdminImageToParcel < ActiveRecord::Migration[5.0]
  def change
    add_column :parcels, :image1, :string
    add_column :parcels, :image2, :string
    add_column :parcels, :image3, :string
    add_column :parcels, :image4, :string
    add_column :parcels, :image5, :string
  end
end
