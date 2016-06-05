class AddColumnsToOrdersForLoadAssociation < ActiveRecord::Migration
  def change
    add_column :orders, :load_id, :integer
    add_column :orders, :position, :integer
    add_column :orders, :reverse, :boolean, default: false
    add_index :orders, :load_id
  end
end
