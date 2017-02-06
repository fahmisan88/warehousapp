class AddExtraRemarkToShipment < ActiveRecord::Migration[5.0]
  def change
    add_column :shipments, :extra_remark, :string
  end
end
