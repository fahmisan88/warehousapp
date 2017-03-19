class AddTrackingToShipment < ActiveRecord::Migration[5.0]
  def change
    add_column :shipments, :tracking, :string
  end
end
