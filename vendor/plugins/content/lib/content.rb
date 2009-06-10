require 'html_content'
require 'component_content'

module Content

  module FLAGS
    #convenience constants, for making code clearer instead of passing "true/false" flags as method params
    # DO NOT MODIFY!!!
    EXPORT_ALL=true
    EXPORT_CHANGES=false
    IMPORT_ALL=true
    IMPORT_CHANGES=false
    WIPE_DESTINY=true
    ADD_TO_DESTINY=false  
  end
  
  _PROJECT_ROOT=FileUtils.pwd
  
#  DEFAULT_TEMPLATE ='content_template_sample' unless defined? Content::DEFAULT_TEMPLATE
#  CONTENT_WEB_PREFIX ='web' unless defined? Content::CONTENT_WEB_PREFIX
#  MAP_HOME_TO_CONTENT = true unless defined? Content::MAP_HOME_TO_CONTENT
#  PUBLISH_PATH = File.join(_PROJECT_ROOT,'app','views','content','publish') unless defined? Content::PUBLISH_PATH
#  EXPORT_PATH = File.join(_PROJECT_ROOT,'app','views','content','export') unless defined? Content::EXPORT_PATH
#  CONTENT_UPLOAD_PATH = '' unless defined? Content::CONTENT_UPLOAD_PATH
#  DB_FORMAT = '%Y-%m-%d %H:%M:%S' unless defined? Content::DB_FORMAT
  
  mattr_accessor :default_template, :web_prefix, :map_home_to_content, :db_format, :default_language 
  mattr_accessor  :publish_path, :export_path, :upload_path, :svn_broadcast_servers
  self.default_template ='content_template_sample'
  self.web_prefix ='web'
  self.map_home_to_content = false 
  self.db_format = '%Y-%m-%d %H:%M:%S'
  self.default_language = 'es'
  self.publish_path = File.join(_PROJECT_ROOT,'app','views','content','publish')
  self.export_path = File.join(_PROJECT_ROOT,'app','views','content','export')
  self.upload_path  = '' 
  self.svn_broadcast_servers=[]
   
  
  
  def self.export(export_all=FLAGS::EXPORT_CHANGES)
    puts "Starting content export. Export_all: #{export_all}"
    FileUtils.mkdir_p(self.export_path)
    obj_time=Time.now
    ContentRole.update_all('published_id=id')
    arr_roles=ContentRole.find(:all )    
    marshal_and_save(arr_roles,'content_roles', 1, obj_time)    
    
    ContentPage.update_all('published_id=id')
    conditions = nil
    
    unless export_all
      last_export=ContentPublishAction.last_export
      conditions= [ """content_pages.updated_at > :last_export 
        OR html_contents.updated_at >  :last_export 
        OR component_contents.updated_at >  :last_export""",
        {:last_export=>last_export.created_at.strftime(self.db_format)}] if last_export
    end
    
    arr_pages=ContentPage.find(:all,:include=>[:html_contents,:component_contents], :conditions=>conditions)
    content_pages=arr_pages.map{|p| p.attributes}.compact
    marshal_and_save(content_pages,'content_pages',2,obj_time) unless content_pages.empty?
    html_contents=arr_pages.map{|p| p.html_contents}.flatten.compact 
    marshal_and_save(html_contents,'html_contents',3,obj_time) unless html_contents.empty?
    component_contents = arr_pages.map{|p| p.component_contents}.flatten.compact
    marshal_and_save(component_contents,'component_contents',4,obj_time) unless component_contents.empty?
    
    ContentPublishAction.export_mark
    puts "Finishing content export"
  end #export
  
  def self.import(import_all=FLAGS::IMPORT_CHANGES,wipe_destiny=FLAGS::ADD_TO_DESTINY)
    puts "Starting content import. Import_all: #{import_all}; Wipe_Destiny: #{wipe_destiny}"
    
    arr_exports=Dir.entries(self.export_path).delete_if{|e| e=~ /^\./}.sort     
     unless import_all
       last_import=ContentPublishAction.last_import
       if last_import
        last_import_time=get_timestamp(last_import[:created_at])
        timestamp_length=last_import_time.size        
        arr_exports.delete_if{|e| e[0...timestamp_length] < last_import_time}          
       end
     end
     
     if wipe_destiny
       puts "please confirm you want to remove the existing contents (type 'yes' to confirm, or anything else to skip)"
       s_answer=$stdin.gets
       if s_answer.chomp == 'yes'
         puts "deleting existing contents"
         ComponentContent.delete_all
         HtmlContent.delete_all
         ContentPage.update_all('parent_id=NULL')
         ContentPage.delete_all
         ContentRole.delete_all  
       else
          puts "contents deletion skipped"
       end            
     end
     
     ContentRole.update_all('published_id=NULL')    
     ContentPage.update_all('published_id=NULL')
      
     arr_exports.each do |export|
        name_parts= /(.*)_(step_[0-9]+)_([^\.]+)\.marshal/.match(export) #1st group is datetime, 2nd is step_99, 3rd is the table_name
        next if name_parts.nil?
        self.send("import_#{name_parts[3]}",File.join(self.export_path,export)) #it will call for example "self.import_content_roles(export_file_name)"
     end
     ContentPublishAction.import_mark
     puts "Finishing content import"
  end #import
  
  
  
  def self.publish    
    puts "Starting content publication"
    arr_pages = ContentPage.find(:all,:include=>:html_contents)
    arr_pages.each do |page|    
      str_root = (page.page_path == '/') ? '#root' : '#root/'
      str_page_dir = File.join(self.publish_path,page.page_path.downcase.sub(/^\//,str_root))    
      str_page_dir += '.page' unless page.page_template.blank?
      FileUtils.mkdir_p str_page_dir
      File.open(File.join(str_page_dir,'attributes.yaml'),'w') do |att|
        att.puts(page.attributes.to_yaml)
      end #file open
      self.add_path_to_svn(str_page_dir)
      self.add_path_to_svn(File.join(str_page_dir,'attributes.yaml'))
      
      unless page.html_contents.empty?
        str_content_dir=File.join(str_page_dir,'contents.html_contents')
        FileUtils.mkdir_p str_content_dir
        self.add_path_to_svn(str_content_dir)
        
        page.html_contents.each do |content|
          next unless content.version==1
          str_locale_dir = File.join(str_content_dir,content.language)
          FileUtils.mkdir_p str_locale_dir
          self.add_path_to_svn(str_locale_dir)
          File.open(File.join(str_locale_dir,"_#{content.area}.html"),'w') do |area|
            area.puts content.content
          end #file open
           self.add_path_to_svn(File.join(str_locale_dir,"_#{content.area}.html"))
        end #html_contents each
      end #unless html_contents empty
    end #arr_pages each 
    ContentPublishAction.publication_mark
    puts "Finishing content publication"
    
    puts "Calling after_publish method"    
    begin
      self.after_publish
    rescue Exception => e
      puts "error when running after_publish actions. The reported message was:"
      puts e.message
    else
      puts "after_publish actions finished successfully"
    end    
  end #def publish
  
  private  
  def self.marshal_and_save(obj,name,step,time_obj)
    marshal_file=File.join(self.export_path,"#{self.get_timestamp(time_obj)}_step_#{step}_#{name}.marshal")
    File.open(marshal_file,'wb') do |file|
            file.puts Marshal.dump(obj)
    end #file open
     self.add_path_to_svn marshal_file
  end #marshal_and_save
  
  def self.get_timestamp(time_obj)     
    time_obj.strftime('%Y%m%d_%H%M%S')
  end #get_timestamp
  
  def self.get_binary_file_contents(filename)
    file_content=nil
    File.open(filename,'rb') do |file|
            file_content = file.read
    end #file open
  end #get_binary_file_contents
  
  def self.import_content_roles(filename)    
    arr_roles=Marshal.load(File.read(filename))
    arr_roles.each do |role|
      db_role=ContentRole.find_or_initialize_by_name(role.name)      
      db_role.attributes=db_role.attributes.merge(role.attributes)      
      db_role.save!
    end
  end #import_content_roles
  
  def self.import_content_pages(filename)     
    #each of the pages is not a ContentPage object but a hash (we stored the attributes hash)
    #So we cannot access the fields with . or : but as a string
    arr_pages=Marshal.load(get_binary_file_contents(filename))
    arr_pages.each do |page|      
      db_page=ContentPage.find_or_initialize_by_page_path(page['page_path'])      
      db_page.attributes=db_page.attributes.merge(page)      
      db_page.parent_id=nil
      db_page.content_role = ContentRole.find_by_published_id(db_page.content_role_id) if db_page.content_role        
      db_page.save!
    end
    
    #and now another round to set the parent_id. Since it refers to same table, we couldn't do it on first
    #try because of referential integrity
    arr_pages.each do |page|
      if page['parent_id']        
        db_page=ContentPage.find_by_page_path(page['page_path'])
        db_page.parent = ContentPage.find_by_published_id(page['parent_id'])
        db_page.save!
      end
    end
  end #import_content_pages
  
  def self.import_html_contents(filename)
    #HtmlContent.find(:all)    
    arr_contents=Marshal.load(get_binary_file_contents(filename))
    arr_contents.each do |cnt|
      next if cnt.version == 0 #we only import current versions
      cnt.content_page = ContentPage.find_by_published_id(cnt.content_page_id)      
      db_cnt=HtmlContent.find_or_create_by_content_page_id_and_area_and_language_and_version(cnt.content_page.id,cnt.area,cnt.language,1)      
      db_cnt.attributes=db_cnt.attributes.merge(cnt.attributes)      
      db_cnt.save!
    end
  end #import_html_contents
  
  def self.import_component_contents(filename)  
    #ComponentContent.find(:all)
    arr_contents=Marshal.load(get_binary_file_contents(filename))
    arr_contents.each do |cnt|      
      next if cnt.version == 0 #we only import current versions
      cnt.content_page = ContentPage.find_by_published_id(cnt.content_page_id)
      db_cnt=ComponentContent.find_or_create_by_content_page_id_and_area_and_version(cnt.content_page.id,cnt.area,1)      
      db_cnt.attributes=db_cnt.attributes.merge(cnt.attributes)      
      db_cnt.save!
    end
  end #import_component_contents
  
  #this method should be overwritten by opening Content in some user class loaded
  #at start-up time in case we need extra tasks to run after publishing. Typically
  #it will be used for cache cleaning
  def self.after_publish    
    return true #any errors should be reported by raising an exception with a message
  end
  
  def self.add_path_to_svn(path,broadcast=true)
    return false if path.blank? ||  svn_broadcast_servers.empty?
    
    path=File.expand_path path
    directory=File.directory?(path)    
    error = false
    Dir.chdir(File.dirname(path)) do
      system "svn add -q --force #{File.basename(path)}"
      system "svn commit -q -m \"automatically commited from content manager\" #{File.basename(path)}"
    end
    
    base_path = File.expand_path RAILS_ROOT
    
    error = self.broadcast_svn_update(path) if broadcast
    
    return error
  end
  
  def self.broadcast_svn_update(path)
    base_path = File.expand_path RAILS_ROOT
    path.sub!(base_path,'')
    error = false
    svn_broadcast_servers.each do |server|      
     begin
       Net::HTTP.get(server.split(':')[0],"/content/svn_update?path=#{path}",server.split(':')[1])
     rescue Exception => e
      error = true
     end
    end #each server
    return error
  end
end #module