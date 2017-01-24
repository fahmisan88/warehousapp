class AddPackageExpiryToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :package, :integer
    add_column :users, :expiry, :datetime
  end
end
