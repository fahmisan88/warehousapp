class AddRmb2MyrToCurrency < ActiveRecord::Migration[5.0]
  def change
    add_column :currencies, :rmb2myr, :decimal
  end
end
