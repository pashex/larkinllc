class AddReverseVolumeToLoads < ActiveRecord::Migration
  def change
    change_table :loads do |t|
      t.float :reverse_volume, default: 0.0, null: false
      t.integer :reverse_quantity, default: 0, null: false
    end
  end
end
