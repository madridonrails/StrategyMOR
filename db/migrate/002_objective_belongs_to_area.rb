class ObjectiveBelongsToArea < ActiveRecord::Migration
  def self.up
    add_column :perspectives, :area_id, :integer, :null => false
    remove_column :objectives, :area_id
  end

  def self.down
    add_column :objectives, :area_id, :integer, :null => false
    remove_column :perspectives, :area_id
  end
end
