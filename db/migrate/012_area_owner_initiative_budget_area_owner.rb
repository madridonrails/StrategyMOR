class AreaOwnerInitiativeBudgetAreaOwner < ActiveRecord::Migration
  def self.up
    add_column :areas, :owner, :integer, :null => false
    add_column :initiatives, :budget, :float
    add_column :initiatives, :budget_attribute, :string
  	change_column :objectives, :target, :float, :default => 0.0
  	change_column :objectives, :value, :float, :default => 0.0
  	change_column :objectives, :upper_limit, :float, :default => 0.0
  	change_column :objectives, :lower_limit, :float, :default => 0.0
  	change_column :checkpoints, :target, :float, :default => 0.0
  	change_column :checkpoints, :value, :float, :default => 0.0
  	change_column :checkpoints, :upper_limit, :float, :default => 0.0
  	change_column :checkpoints, :lower_limit, :float, :default => 0.0
    add_column :objectives, :symbol, :string
  end

  def self.down
    remove_column :objectives, :symbol
  	change_column :checkpoints, :lower_limit, :float
  	change_column :checkpoints, :upper_limit, :float
  	change_column :checkpoints, :value, :float
  	change_column :checkpoints, :target, :float
  	change_column :objectives, :lower_limit, :float
  	change_column :objectives, :upper_limit, :float
  	change_column :objectives, :value, :float
  	change_column :objectives, :target, :float
    remove_column :initiatives, :budget_attribute
    remove_column :initiatives, :budget
    remove_column :areas, :owner
  end
end
