class AddCompletedColumnToLoads < ActiveRecord::Migration
  def change
    add_column :loads, :completed, :boolean, default: false
  end
end
