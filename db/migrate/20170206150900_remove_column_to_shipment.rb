class RemoveColumnToShipment < ActiveRecord::Migration[5.0]
  def change
    remove_column :shipments, :weight, :integer
    remove_column :shipments, :volume, :integer
    remove_column :shipments, :chargeable, :decimal
  end
end
