class AddIndexForOrders < ActiveRecord::Migration
  def change
    add_index :orders, :number
    add_index :orders, :origin_id
    add_index :orders, :destination_id
  end
end
