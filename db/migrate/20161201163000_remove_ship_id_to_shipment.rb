class RemoveShipIdToShipment < ActiveRecord::Migration[5.0]
  def change
    remove_column :shipments, :shipid, :string
  end
end
