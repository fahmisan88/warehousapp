class AddEziIdToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :ezi_id, :integer, :default => 0, :null => false
  end
end
