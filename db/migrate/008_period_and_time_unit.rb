class PeriodAndTimeUnit < ActiveRecord::Migration
  def self.up
    remove_column :periods, :name
    add_column :periods, :time_unit_id, :integer, :null => false
    create_table "time_units", :force => true do |t|
      t.column "name", :string, :default => "", :null => false
      t.column "adjective", :string, :default => "", :null => false
      t.column "days", :integer, :null => false
    end
  end

  def self.down
    add_column :periods, :name, :string, :default => "", :null => false
    remove_column :periods, :time_unit_id
	drop_table :time_units
  end
end
