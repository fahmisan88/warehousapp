class AddRemarkAdminToShipment < ActiveRecord::Migration[5.0]
  def change
    add_column :shipments, :remark_admin, :string
  end
end
