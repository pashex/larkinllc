class MovePhoneFromLocationsToOrders < ActiveRecord::Migration
  def up
    add_column :orders, :phone, :string
    remove_column :locations, :phone
  end

  def down
    add_column :locations, :phone, :string
    remove_column :orders, :phone
  end
end
