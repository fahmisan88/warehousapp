class AddAddress2ToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :address2, :string
  end
end
