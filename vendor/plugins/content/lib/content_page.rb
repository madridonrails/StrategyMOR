class ContentPage < ActiveRecord::Base
  acts_as_tree :order=>:position
      
  has_many :html_contents, :dependent => :delete_all
  has_many :component_contents, :dependent => :delete_all
  
  belongs_to :content_role
  before_save 'normalize_path'
  before_create 'set_title'
  
  def validate_on_create
    obj_page = ContentPage.find_by_page_path(ContentStrNormalizer.normalize(self.page_path))
    
    errors.add :page_path, "Ya existe una página con la misma ruta" unless obj_page.nil?
  end
  
  def child_pages
    ContentPage.find_all_by_parent_id(self.id,:conditions=>"page_template IS NOT NULL and page_template<>''", :order=>'position', :include=>:content_role)
  end
  
  
  def page_siblings
    ContentPage.find_all_by_parent_id(self.parent_id, :conditions=>"page_path like '/%' and page_template IS NOT NULL and page_template<>''", :order=>'position', :include=>:content_role)          
  end
  
  def child_sections
    ContentPage.find_all_by_parent_id(self.id,:conditions=>"page_template IS NULL or page_template=''", :order=>'position', :include=>:content_role)
  end
  
  def normalize_path    
    self.page_path = ContentStrNormalizer.normalize(self.page_path)
  end
  
  def set_title
    self.title = self.page_path.split('/')[-1] if self.title.blank?
  end

end
