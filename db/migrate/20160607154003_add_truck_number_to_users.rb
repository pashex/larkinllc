class AddTruckNumberToUsers < ActiveRecord::Migration
  def change
    add_column :users, :truck_number, :integer, default: 0
  end
end
