class CreateShipments < ActiveRecord::Migration[5.0]
  def change
    create_table :shipments do |t|
      t.integer :user_id
      t.string :remark
      t.integer :weight
      t.integer :volume
      t.integer :status
      t.integer :type
      t.decimal :charge
      t.string :bill_id
      t.datetime :due_at
      t.datetime :paid_at
      t.string :bill_url

      t.timestamps
    end
  end
end
