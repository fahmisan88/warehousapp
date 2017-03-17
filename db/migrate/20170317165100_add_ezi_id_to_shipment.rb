class AddEziIdToShipment < ActiveRecord::Migration[5.0]
  def change
    add_column :shipments, :ezi_id, :string
  end
end
