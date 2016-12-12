class AddExtraToShipment < ActiveRecord::Migration[5.0]
  def change
    add_column :shipments, :reorganize, :boolean
    add_column :shipments, :repackaging, :boolean
  end
end
