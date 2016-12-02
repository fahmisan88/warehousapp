class AddShipIdToShipment < ActiveRecord::Migration[5.0]
  def change
    add_column :shipments, :shipid, :string
  end
end
