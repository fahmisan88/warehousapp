class ChangeImageFromAdmin < ActiveRecord::Migration[5.0]
  def change
    add_column :parcels, :image_admin, :string, array: true, default: []
  end
end
