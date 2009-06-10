class OrderInObjsAndPersps < ActiveRecord::Migration
  def self.up
    add_column :perspectives, :order_number, :integer, :null => false
    add_column :objectives, :order_number, :integer, :null => false
  end

  def self.down
    remove_column :objectives, :order_number
    remove_column :perspectives, :order_number
  end
end
