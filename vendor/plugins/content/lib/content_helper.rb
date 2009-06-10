module ContentHelper
  include ContentPermissionsHelper rescue nil
  
  #gets html_content for a page and area. We can force a non_editable area and a no control header
  #if login as content admin and not hide_admin option is provided, we will render fresh content from
  #database. Otherwise, we will render the published file
  def get_html_content(page_path, area, b_is_editable = true, b_force_control_header=false,editor_width=650,editor_height=500)
   str_output=String.new
   if ((defined?(@hide_admin).nil? || @hide_admin.blank?) )
    obj_content = HtmlContent.get_by_page_path_and_area(page_path, area, content_language)   
    b_is_shared = page_path.starts_with? '_'
    control_header = render(:partial=>'content/content_templates/control_header', :locals=>{:page_path=>page_path, :area=>area, :b_is_page_shared=>b_is_shared, :b_is_editable_area => b_is_editable, :content_type=>'html', :b_force_control_header=> b_force_control_header, :editor_width=>editor_width,:editor_height=>editor_height} ) 
    content_div=render(:partial=>'content/content_templates/html_content', :locals=>{:obj_content=>obj_content} ) 
    str_output=control_header + content_div
   else         
    str_root = (page_path == '/') ? '#root' : '#root/'
	  str_content_dir = File.join(Content.publish_path,"#{page_path.downcase.sub(/^\//,str_root)}.page",'contents.html_contents')    
    str_file_name = File.join(str_content_dir,content_language,"_#{area}.html")
    #in case the file doesn't exists, we'll try to get the one in the default content language
    str_file_name = File.join(str_content_dir,Content.default_language,"_#{area}.html") unless File.exists?(str_file_name)
    str_output=(File.read(str_file_name)) rescue ''
    str_output="<!-- html_content #{area} begin -->\n"+str_output+"<!-- html_content #{area} end -->\n"
   end
   
   return str_output
  end

  def get_html_text(page_path, area, b_is_editable = true, b_force_control_header=false,editor_width=650,editor_height=500)
   str_output=String.new
   if ((defined?(@hide_admin).nil? || @hide_admin.blank?) )
    obj_content = HtmlContent.get_by_page_path_and_area(page_path, area, content_language)
    str_output = obj_content.content
   else         
    str_root = (page_path == '/') ? '#root' : '#root/'
	  str_content_dir = File.join(Content.publish_path,"#{page_path.downcase.sub(/^\//,str_root)}.page",'contents.html_contents')    
    str_file_name = File.join(str_content_dir,content_language,"_#{area}.html")
    #in case the file doesn't exists, we'll try to get the one in the default content language
    str_file_name = File.join(str_content_dir,Content.default_language,"_#{area}.html") unless File.exists?(str_file_name)
    str_output = (File.read(str_file_name)) rescue ''
    str_output = str_output
   end
   
   return str_output
  end
  
  #gets component_content for a page and area. We can force a non_editable area and a no control header
  def get_component_content(page_path, area, b_is_editable = true, b_force_control_header=false )   
   obj_content = ComponentContent.get_by_page_path_and_area(page_path, area)
   b_is_shared = page_path.starts_with? '_'  
   control_header = render(:partial=>'content/content_templates/control_header', :locals=>{:page_path=>page_path, :area=>area, :b_is_page_shared=>b_is_shared, :b_is_editable_area => b_is_editable,:content_type=>'component',:b_force_control_header=> b_force_control_header} ) 
   
   str_partial = obj_content.component.blank? ? nil : "content/components/#{obj_content.component}/component_content"   
   content_div=render(:partial=>'content/content_templates/component_content', :locals=>{:obj_content=>obj_content, :component_partial=>str_partial }) 
   
   return control_header + content_div  
  end
  
  #gets component_content by name. Non editable. We can force a no control header
  def get_component(component_name, page_path=nil,b_force_control_header=false)     
   control_header = render(:partial=>'content/content_templates/control_header', :locals=>{:b_is_editable_area => false,:content_type=>'component',:b_force_control_header=> b_force_control_header} ) 
   content_div=render(:partial=>'content/content_templates/component_content', :locals=>{:component_partial=>"content/components/#{component_name}/component_content", :page_path=>page_path }) 
   return control_header + content_div
  end
  
  #select with a list of defined components
  def options_for_component_list(selected_option='')
     arr_entries = Dir.entries("#{RAILS_ROOT}/app/views/content/components").map  do |m|
          m=nil if m=~(/^\.+/)
         m.blank? ? nil : [m.titleize,m]
    end
    return options_for_select(arr_entries.compact, selected_option)
  end

  #select with a list of defined templates
  def options_for_template_list(selected_option='')
     arr_entries = Dir.entries("#{RAILS_ROOT}/app/views/content/page_templates").map {|m| m.sub!(/^_/,'') and m.gsub!(/\.rhtml/,'') and [m.titleize,m]}.compact.sort
    return options_for_select(arr_entries.compact, selected_option)
  end
  
  #sibling pages for our page. Page can be either a ContentPage object or an id
  def sibling_page_list(page)      
    if !(page.is_a? ContentPage)
      page = ContentPage.find(page) rescue nil
    end    
    return [] if page.nil?    
    #only pages starting by '/', so internal pages like _global will not be retrieved
    return page.page_siblings     
  end

  #child_sections for our page. Page can be either a ContentPage object or an id.Page defaults to "/"
  def child_section_list(page) 
    if (page.nil?)     
      page = ContentPage.find_by_page_path('/')
    elsif !(page.is_a? ContentPage)
      page = ContentPage.find(page) rescue nil
    end
    
    return [] if page.nil?    
    #only pages starting by '/', so internal pages like _GLOBAL will not be retrieved
    return page.child_sections
  end
  
  #ContentPage object for the given path
  def get_page_for_page_path (page_path)
        ContentPage.find_by_page_path(page_path)
  end  
  
  #default javascript/css tags for rendering contents
  def content_include_tag
    str_js = javascript_include_tag('content/content', 'windows/window')
    str_css = stylesheet_link_tag('windows/themes/default','content/content_admin')
    "#{str_js}#{str_css}"
  end
  
  #returns page tree. unfinished XXX
  def page_tree(initial_page)    
    page_tree ||= Hash.new
    begin
    base_path=if initial_page.is_a? String
        base_path
      elsif initial_page.is_a? ContentPage
        initial_page.page_path
      else
        nil
    end #if

    raise if base_path.nil?
    base_path=base_path+'/' if base_path[-1..-1]!='/' #if it doesn't finishes with '/' we add it
    pages=ContentPage.find(:all,:select=>'page_path,title,page_template',
                                      :conditions=>['page_path like ?',"#{base_path}%"],:order=>'page_template')
    i_len=base_path.size                                 
    pages.each do |page|
      path=page.page_path[i_len..-1]
      
      if page.page_template.blank?
        template=page_tree[page_template]
      end
    end                                  
    rescue Exception
      #we rescue all exceptions just for error/flow control
    end
    return page_tree
  end
end
