class CreateLoads < ActiveRecord::Migration
  def change
    create_table :loads do |t|
      t.date :delivery_date
      t.integer :shift, default: 1
      t.float :volume, default: 0.0, null: false
      t.integer :quantity, default: 0, null: false
      t.timestamps null: false
    end
  end
end
