class EliminateUserDefaults < ActiveRecord::Migration
  def self.up
    change_column 'users', 'profile_id', :integer, :default => nil
    change_column 'users', 'enterprise_id', :integer, :default => nil
  end

  def self.down
    change_column 'users', 'enterprise_id', :integer, :default => 0, :null => false
    change_column 'users', 'profile_id', :integer, :default => 0, :null => false
  end
end
