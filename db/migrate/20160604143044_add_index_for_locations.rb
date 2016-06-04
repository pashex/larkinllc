class AddIndexForLocations < ActiveRecord::Migration
  def change
    add_index :locations, :name
    add_index :locations, :address
  end
end
