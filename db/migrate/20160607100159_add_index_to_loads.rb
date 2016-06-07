class AddIndexToLoads < ActiveRecord::Migration
  def change
    add_index :loads, :delivery_date
    add_index :loads, [:delivery_date, :shift]
  end
end
