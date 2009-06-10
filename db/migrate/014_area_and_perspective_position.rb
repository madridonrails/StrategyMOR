class AreaAndPerspectivePosition < ActiveRecord::Migration
  def self.up
    rename_column :objectives, :order_number, 'position'
    rename_column :perspectives, :order_number, 'position'
  end

  def self.down
    rename_column :objectives, 'position', 'order_number'
    rename_column :perspectives, 'position', 'order_number'
  end
end
