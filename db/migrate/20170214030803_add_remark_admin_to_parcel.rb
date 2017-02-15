class AddRemarkAdminToParcel < ActiveRecord::Migration[5.0]
  def change
    add_column :parcels, :remark_admin, :string
  end
end
