class AddRefundExplainToParcel < ActiveRecord::Migration[5.0]
  def change
    add_column :parcels, :refund_explain, :string
  end
end
