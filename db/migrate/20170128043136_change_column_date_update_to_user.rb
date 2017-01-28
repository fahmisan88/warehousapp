class ChangeColumnDateUpdateToUser < ActiveRecord::Migration[5.0]
  def change
    change_column_default(:users, :updated_at, Time.now)
  end
end
