class CratedUpdatedInAllTables < ActiveRecord::Migration
  def self.up
    add_column    :affects, 'created_at', :timestamp
    add_column    :affects, 'updated_at', :timestamp
    add_column    :areas, 'created_at', :timestamp
    add_column    :areas, 'updated_at', :timestamp
    add_column    :checkpoints, 'created_at', :timestamp
    add_column    :checkpoints, 'updated_at', :timestamp
    add_column    :enterprises, 'created_at', :timestamp
    add_column    :enterprises, 'updated_at', :timestamp
    add_column    :initiatives, 'created_at', :timestamp
    add_column    :initiatives, 'updated_at', :timestamp
    add_column    :objectives, 'created_at', :timestamp
    add_column    :objectives, 'updated_at', :timestamp
    add_column    :periods, 'created_at', :timestamp
    add_column    :periods, 'updated_at', :timestamp
    add_column    :perspectives, 'created_at', :timestamp
    add_column    :perspectives, 'updated_at', :timestamp
    add_column    :profiles, 'created_at', :timestamp
    add_column    :profiles, 'updated_at', :timestamp
    add_column    :time_units, 'created_at', :timestamp
    add_column    :time_units, 'updated_at', :timestamp
  end

  def self.down
    remove_column    :affects, 'created_at'
    remove_column    :affects, 'updated_at'
    remove_column    :areas, 'created_at'
    remove_column    :areas, 'updated_at'
    remove_column    :checkpoints, 'created_at'
    remove_column    :checkpoints, 'updated_at'
    remove_column    :enterprises, 'created_at'
    remove_column    :enterprises, 'updated_at'
    remove_column    :initiatives, 'created_at'
    remove_column    :initiatives, 'updated_at'
    remove_column    :objectives, 'created_at'
    remove_column    :objectives, 'updated_at'
    remove_column    :periods, 'created_at'
    remove_column    :periods, 'updated_at'
    remove_column    :perspectives, 'created_at'
    remove_column    :perspectives, 'updated_at'
    remove_column    :profiles, 'created_at'
    remove_column    :profiles, 'updated_at'
    remove_column    :time_units, 'created_at'
    remove_column    :time_units, 'updated_at'
  end
end
