class InitialSchema < ActiveRecord::Migration
  def self.up

    create_table "affects", :force => true do |t|
      t.column "affects", :integer, :null => false
      t.column "is_affected", :integer, :null => false
    end

    add_index "affects", ["affects", "is_affected"], :name => "affects", :unique => true

    create_table "areas", :force => true do |t|
      t.column "name", :string, :default => "", :null => false
      t.column "enterprise_id", :integer, :null => false
    end

    create_table "enterprises", :force => true do |t|
      t.column "name", :string, :default => "", :null => false
      t.column "logo", :string
      t.column "css", :string
      t.column "contact", :string
    end

    create_table "initiatives", :force => true do |t|
      t.column "name", :string, :default => "", :null => false
      t.column "description", :string
      t.column "objective_id", :integer, :null => false
      t.column "ini_date", :integer, :limit => 8
      t.column "end_date", :integer, :limit => 8
      t.column "assigned_to", :integer
    end

    create_table "objectives", :force => true do |t|
      t.column "area_id", :integer, :null => false
      t.column "creator", :integer, :null => false
      t.column "updater", :integer, :null => false
      t.column "period_id", :integer, :null => false
      t.column "name", :string, :default => "", :null => false
      t.column "description", :string
      t.column "lower_limit", :integer, :null => false
      t.column "target", :integer, :null => false
      t.column "upper_limit", :integer, :null => false
      t.column "perspective_id", :integer, :null => false
    end

    create_table "periods", :force => true do |t|
      t.column "name", :string, :default => "", :null => false
      t.column "days", :integer, :null => false
    end

    create_table "perspectives", :force => true do |t|
      t.column "name", :string, :default => "", :null => false
    end
 
    create_table "profiles", :force => true do |t|
      t.column "name", :string, :default => "", :null => false
      t.column "privilege1", :string, :limit => 1, :default => "N"
      t.column "privilege2", :string, :limit => 1, :default => "N"
      t.column "privilege3", :string, :limit => 1, :default => "N"
      t.column "privilege4", :string, :limit => 1, :default => "N"
      t.column "privilege5", :string, :limit => 1, :default => "N"
      t.column "privilege6", :string, :limit => 1, :default => "N"
      t.column "privilege7", :string, :limit => 1, :default => "N"
      t.column "privilege8", :string, :limit => 1, :default => "N"
    end

    create_table "users", :force => true do |t|
      t.column "profile_id", :integer, :default => 0, :null => false
      t.column "first_name", :string
      t.column "first_name_for_sorting", :string
      t.column "last_name", :string
      t.column "last_name_for_sorting", :string
      t.column "login", :string, :default => "", :null => false
      t.column "password", :string, :limit => 32, :default => "", :null => false
      t.column "supervisor_id", :integer
      t.column "enterprise_id", :integer, :default => 0, :null => false
    end
  end
  
  def self.down
    drop_table :initiatives
	drop_table :affects
	drop_table :objectives
	drop_table :areas
	drop_table :perspectives
    drop_table :users
    drop_table :enterprises
	drop_table :periods
	drop_table :profiles
  end
end
