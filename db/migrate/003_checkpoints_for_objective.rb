class CheckpointsForObjective < ActiveRecord::Migration
  def self.up
    add_column :objectives, :value, :integer, :null => false

    create_table "checkpoints", :force => true do |t|
      t.column "objective_id", :integer, :null => false
      t.column "updater", :integer, :null => false
      t.column "lower_limit", :integer, :null => false
      t.column "target", :integer, :null => false
      t.column "value", :integer, :null => false
      t.column "upper_limit", :integer, :null => false
      t.column "update_date", :integer, :limit => 8
      t.column "comments", :string
    end
  end

  def self.down
    remove_column :objectives, :value

	drop_table :checkpoints
  end
end
