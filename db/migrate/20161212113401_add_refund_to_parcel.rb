class AddRefundToParcel < ActiveRecord::Migration[5.0]
  def change
    add_column :parcels, :refund, :boolean
  end
end
