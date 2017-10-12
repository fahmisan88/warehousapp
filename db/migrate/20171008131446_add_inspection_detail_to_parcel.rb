class AddInspectionDetailToParcel < ActiveRecord::Migration[5.0]
  def change
    add_column :parcels, :inspection_detail, :string
  end
end
