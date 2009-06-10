class CreateUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :password
    add_column :users, :email, :string
    add_column :users, :crypted_password, :string, :limit => 40
    add_column :users, :salt, :string, :limit => 40
    add_column :users, :created_at, :datetime
    add_column :users, :updated_at, :datetime
    add_column :users, :remember_token, :string
    add_column :users, :remember_token_expires_at, :datetime
  end

  def self.down
    add_column :users, :password, :string, :limit => 32, :default => "", :null => false
    remove_column :users, :email
    remove_column :users, :crypted_password
    remove_column :users, :salt
    remove_column :users, :created_at
    remove_column :users, :updated_at
    remove_column :users, :remember_token
    remove_column :users, :remember_token_expires_at
  end
end
