class AddColumnToParcel < ActiveRecord::Migration[5.0]
  def change
    add_column :parcels, :product_quantity, :int
    add_column :parcels, :price_per_unit, :decimal
    add_column :parcels, :product_total_price, :decimal
    add_column :parcels, :product_chinese, :string
  end
end
