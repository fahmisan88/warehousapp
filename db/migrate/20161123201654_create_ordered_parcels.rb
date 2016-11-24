class CreateOrderedParcels < ActiveRecord::Migration[5.0]
  def change
    create_table :ordered_parcels do |t|
      t.integer :parcel_id
      t.integer :shipment_id

      t.timestamps
    end
  end
end
