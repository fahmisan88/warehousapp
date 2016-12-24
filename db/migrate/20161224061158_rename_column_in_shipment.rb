class RenameColumnInShipment < ActiveRecord::Migration[5.0]
  def change
    rename_column :shipments, :type, :shipment_type
  end
end
