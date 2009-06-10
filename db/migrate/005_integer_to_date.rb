class IntegerToDate < ActiveRecord::Migration
  def self.up
    change_column :initiatives, :ini_date, :date
    change_column :initiatives, :end_date, :date
    change_column :checkpoints, :update_date, :date
  end

  def self.down
    change_column :initiatives, :ini_date, :integer, :limit => 8
    change_column :initiatives, :end_date, :integer, :limit => 8
    change_column :checkpoints, :update_date, :integer, :limit => 8
  end
end

