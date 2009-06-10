class ComponentContent < ActiveRecord::Base
  belongs_to :content_page
  before_update :version_backup
  
 def self.get_by_page_path_and_area(page_path, area,version=1)  
    obj_content = ComponentContent.find_by_area_and_version(area,version,:include=>:content_page,:conditions=>"content_pages.page_path='#{page_path.downcase.underscore}'")
    
    if obj_content.nil? && version==1
      obj_content = ComponentContent.new      
      obj_content.content_page = ContentPage.find_by_page_path(page_path.downcase.underscore)
      obj_content.area = area.downcase.underscore
      obj_content.component= ''
     end
     return obj_content
  end
  
  def version_backup     
    #we remove the old version, id there is one
    backup_version = ComponentContent.find_by_version_and_content_page_id_and_area(0,self.content_page_id, self.area)
    backup_version.destroy unless backup_version.nil?
    
    #now we retrieve the current version, and we create a new versioned row by copying it
    current_version = ComponentContent.find_by_content_page_id_and_area_and_version(self.content_page_id,self.area,1)    
    current_version = ComponentContent.new(current_version.attributes)    
    current_version.version = 0
    current_version.save
    
    #and we can now mark the current object with the live version number
    self.version = 1
  end
  
end
