class EnterpriseAlias < ActiveRecord::Migration
  def self.up
    add_column :enterprises, :alias, :string, :default => "", :null => false
  end

  def self.down
    remove_column :enterprises, :alias
  end
end
