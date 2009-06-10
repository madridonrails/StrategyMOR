require 'fileutils'

namespace :content do

  desc "Publish content to partials under Content.publish_path dir"
  task :publish => :environment do |t|          
	 Content.publish   
  end #task publish
  
  desc "Export contents. Params: EXPORT_ALL (defaults to false)"
  task :export => :environment do |t|
   b_export_all = ENV['EXPORT_ALL'].to_s.downcase == Content::FLAGS::EXPORT_ALL.to_s
   Content.export b_export_all  
  end #task export
  
  desc "Import contents. Params: IMPORT_ALL (defaults to false), WIPE_DESTINY (defaults to false)"
  task :import=> :environment do |t|
   b_import_all = ENV['IMPORT_ALL'].to_s.downcase == Content::FLAGS::IMPORT_ALL.to_s
   b_wipe_destiny = ENV['WIPE_DESTINY'].to_s.downcase == Content::FLAGS::WIPE_DESTINY.to_s
   Content.import b_import_all, b_wipe_destiny  
  end #task import
  
  desc "Delete content database"
  task :delete_database => :environment do |t|      
    down
  end #task delete_database
  
  desc "Initialize content database"
  task :initialize_database => :environment do |t|      
    up
     p = ContentPage.new
     p.page_path = '_global'
     p.page_template = '???'
     p.title = '_global'
     p.save!
     
     p = ContentPage.new
      p.page_path = '/'
      p.title = '/'
      p_index= ContentPage.new
        p_index.page_path = '/index'
        p_index.title = 'index'        
        p_index.page_template = Content.default_template
        p_index.position = 1
      p.children << p_index
     p.save!     
  end #task initialize_database
  

  def down
    
    begin
      ActiveRecord::Base.connection.drop_table :content_publish_actions
    rescue StandardError => e
      puts "problems dropping :content_publish_actions. The message was:"
      puts e.message
    end
      
      
    begin
      ActiveRecord::Base.connection.drop_table :component_contents
    rescue StandardError => e
      puts "problems dropping :component_contents. The message was:"
      puts e.message
    end
    
    begin
      ActiveRecord::Base.connection.drop_table :html_contents
    rescue StandardError => e
      puts "problems dropping :html_contents. The message was:"
      puts e.message
    end
    
   begin
       ActiveRecord::Base.connection.remove_index(:content_pages, :page_path)
    rescue StandardError => e
      puts "problems dropping index(:content_pages, :page_path). The message was:"
      puts e.message
    end
    
    begin
      ActiveRecord::Base.connection.drop_table :content_pages
    rescue StandardError => e
      puts "problems dropping :content_pages. The message was:"
      puts e.message
    end
    
    begin
      ActiveRecord::Base.connection.remove_index(:content_roles, :name)
    rescue StandardError => e
      puts "problems dropping index(:content_roles, :name). The message was:"
      puts e.message
    end
    
    begin
      ActiveRecord::Base.connection.drop_table :content_roles
    rescue StandardError => e
      puts "problems dropping :content_roles. The message was:"
      puts e.message
    end
        
  end #down
  
  def up
    str_options = case ActiveRecord::Base.connection.adapter_name.downcase
      when /mysql[.]*/      
        'ENGINE=InnoDB DEFAULT CHARSET=UTF8'
      else
        ''
      end
      
    begin
      ActiveRecord::Base.connection.create_table :content_roles, :options => str_options, :force => false do |t|
      t.column 'name', :string, :null => false
      t.column 'description', :string, :null => false
      t.column 'role_method', :string
      t.column 'published_id', :integer, :references=>nil
      t.column 'created_at', :timestamp
      t.column 'updated_at', :timestamp      
    end      
    ActiveRecord::Base.connection.add_index(:content_roles, :name, :unique => true)
    rescue StandardError => e
      puts "problems creating :content_roles. The message was:"
      puts e.message
    end
    
    
    begin
      ActiveRecord::Base.connection.create_table :content_pages, :options => str_options, :force => false do |t|
      t.column 'parent_id', :integer, :references=>:content_pages
      t.column 'content_role_id', :integer
	    t.column 'title', :string, :default => "", :null => false
      t.column 'page_path', :string, :default => "", :null => false
      t.column 'page_template', :string, :default => ""
      t.column 'position', :integer
      t.column 'published_id', :integer, :references=>nil
      t.column 'created_at', :timestamp
      t.column 'updated_at', :timestamp      
    end
    ActiveRecord::Base.connection.add_index(:content_pages, :page_path, :unique => true)
    rescue StandardError => e
      puts "problems creating :content_pages. The message was:"
      puts e.message
    end
    
    
    begin
      ActiveRecord::Base.connection.create_table :html_contents, :options => str_options, :force => false do |t|
      t.column 'content_page_id', :integer, :default => 0, :null => false
      t.column 'area', :string, :default => "", :null => false
      t.column 'language', :string, :default => Content.default_language.to_s, :null => false
      t.column 'content', :text
      t.column 'version', :integer, :default=>1
      t.column 'created_at', :timestamp
      t.column 'updated_at', :timestamp
    end
#    ActiveRecord::Base.connection.add_index(:html_contents, [:content_page_id,:area, :language, :version], :unique => true, :name=>'html_contents_unique')
    rescue StandardError => e
      puts "problems creating :html_contents. The message was:"
      puts e.message
    end
    
    
    begin
      ActiveRecord::Base.connection.create_table :component_contents, :options => str_options, :force => false do |t|
      t.column 'content_page_id', :integer, :default => 0, :null => false
      t.column 'area', :string, :default => "", :null => false
      t.column 'component', :string
      t.column 'params', :string
      t.column  'version', :integer, :default=>1      
      t.column  'created_at', :timestamp
      t.column  'updated_at', :timestamp
    end
#    ActiveRecord::Base.connection.add_index(:component_contents, [:content_page_id,:area, :version], :unique => true)
    rescue StandardError => e
      puts "problems creating :component_contents. The message was:"
      puts e.message
    end
    
    
    begin
      ActiveRecord::Base.connection.create_table :content_publish_actions, :options => str_options, :force => false do |t|                  
      t.column 'action_type', :string, :size=>1, :null => false #'I'mport/'E'xport/'P'ublishing
      t.column  'created_at', :timestamp
      t.column  'updated_at', :timestamp
    end
    rescue StandardError => e
      puts "problems creating :content_publish_actions. The message was:"
      puts e.message
    end
    
  end #up


end