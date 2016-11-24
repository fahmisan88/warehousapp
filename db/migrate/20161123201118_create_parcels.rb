class CreateParcels < ActiveRecord::Migration[5.0]
  def change
    create_table :parcels do |t|
      t.string :awb
      t.string :description
      t.string :remark
      t.string :image
      t.integer :user_id
      t.integer :weight
      t.integer :volume
      t.integer :status
      t.integer :parcel_good

      t.timestamps
    end
  end
end
