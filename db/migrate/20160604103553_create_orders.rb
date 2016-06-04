class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.date :delivery_date
      t.integer :shift, default: 0
      t.string :number
      t.float :volume, default: 0.0
      t.integer :quantity, default: 0
      t.integer :origin_id
      t.integer :destination_id
      t.timestamps null: false
    end
  end
end
