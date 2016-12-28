class ChangeColumnNameInCurrency < ActiveRecord::Migration[5.0]
  def change
    rename_column :currencies, :change, :myr2rmb
  end
end
