class EliminateObjectiveDefaults < ActiveRecord::Migration
  def self.up
  	change_column :objectives, :target, :float, :default => nil
  	change_column :objectives, :value, :float, :default => nil
  	change_column :objectives, :upper_limit, :float, :default => nil
  	change_column :objectives, :lower_limit, :float, :default => nil
  	change_column :checkpoints, :target, :float, :default => nil
  	change_column :checkpoints, :value, :float, :default => nil
  	change_column :checkpoints, :upper_limit, :float, :default => nil
  	change_column :checkpoints, :lower_limit, :float, :default => nil
  end

  def self.down
  	change_column :objectives, :target, :float, :default => 0.0
  	change_column :objectives, :value, :float, :default => 0.0
  	change_column :objectives, :upper_limit, :float, :default => 0.0
  	change_column :objectives, :lower_limit, :float, :default => 0.0
  	change_column :checkpoints, :target, :float, :default => 0.0
  	change_column :checkpoints, :value, :float, :default => 0.0
  	change_column :checkpoints, :upper_limit, :float, :default => 0.0
  	change_column :checkpoints, :lower_limit, :float, :default => 0.0
  end
end
