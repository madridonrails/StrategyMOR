class HtmlContent < ActiveRecord::Base
  belongs_to :content_page
  before_update :version_backup
  
  def self.get_by_page_path_and_area(page_path, area,language=Content.default_language,version=1)
  
    obj_content = HtmlContent.find_by_area_and_language_and_version(area,language,version,:include=>:content_page,:conditions=>"content_pages.page_path='#{ContentStrNormalizer.normalize(page_path)}'")
    
    if obj_content.nil? && language != Content.default_language
      obj_content = HtmlContent.find_by_area_and_language_and_version(area,Content.default_language.to_s,version,:include=>:content_page,:conditions=>"content_pages.page_path='#{ContentStrNormalizer.normalize(page_path)}'")      
    end
    if obj_content.nil? && version==1
      obj_content = HtmlContent.new      
      obj_content.content_page = ContentPage.find_by_page_path(ContentStrNormalizer.normalize(page_path))
      obj_content.area = area.downcase.underscore
      obj_content.content = ''
      obj_content.language=language
     end
     return obj_content
  end
  
  def version_backup     
    #we remove the old version, if there is one
    backup_version = HtmlContent.find_by_version_and_content_page_id_and_area_and_language(0,self.content_page_id, self.area,self.language)
    backup_version.destroy unless backup_version.nil?
    
    #now we retrieve the current version, and we create a new versioned row by copying it
    current_version = HtmlContent.find_by_content_page_id_and_area_and_language_and_version(self.content_page_id,self.area,self.language,1)
    current_version = HtmlContent.new(current_version.attributes)    
    current_version.version = 0
    current_version.save
    
    #and we can now mark the current object with the live version number
    self.version = 1
  end
end
