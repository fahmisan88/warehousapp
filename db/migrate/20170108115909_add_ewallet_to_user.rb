class AddEwalletToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :ewallet, :decimal
  end
end
