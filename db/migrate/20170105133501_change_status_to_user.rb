class ChangeStatusToUser < ActiveRecord::Migration[5.0]
  def change
    change_column :users, :status, :int, :default => 0
  end
end
