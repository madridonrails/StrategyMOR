class EmailAsLogin < ActiveRecord::Migration
  def self.up
    remove_column :users, :login
  end

  def self.down
    add_column :users, :login, :string, :default => "", :null => false
  end
end
