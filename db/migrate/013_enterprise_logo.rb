class EnterpriseLogo < ActiveRecord::Migration
  def self.up
    remove_column :enterprises, 'logo'                
    add_column :enterprises, "content_type", :string
    add_column :enterprises, "filename", :string     
    add_column :enterprises, "size", :integer
    add_column :enterprises, "parent_id",  :integer
    add_column :enterprises, "thumbnail", :string
  end

  def self.down
    add_column :enterprises, 'logo', :string
    remove_column :enterprises, "content_type", :string
    remove_column :enterprises, "filename", :string     
    remove_column :enterprises, "size", :integer
    remove_column :enterprises, "parent_id",  :integer
    remove_column :enterprises, "thumbnail", :string
  end
end
