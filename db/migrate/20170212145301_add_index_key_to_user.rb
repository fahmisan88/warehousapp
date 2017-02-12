class AddIndexKeyToUser < ActiveRecord::Migration[5.0]
  def change
    add_index :users, :reset_password_token, unique: true
  end
end
