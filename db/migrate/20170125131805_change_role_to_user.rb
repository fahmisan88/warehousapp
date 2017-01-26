class ChangeRoleToUser < ActiveRecord::Migration[5.0]
  def change
    change_column :users, :role, :int, :default => 0
  end
end
