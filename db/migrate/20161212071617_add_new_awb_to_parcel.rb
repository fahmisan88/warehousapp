class AddNewAwbToParcel < ActiveRecord::Migration[5.0]
  def change
    add_column :parcels, :new_awb, :string
  end
end
