require 'application' #controller is required from a plugin, so we need to specifically require application

#Renders content pages and provides the administration methods for creating/deleting/sorting pages and sections
#/app/content/ContentPermissionsHelper is automatically included, so you can place your role/content methods in
#that helper and they will be automatically recognized. Role/content methods can be defined in any scope
#where the controller has visibility (i.e. ApplicationController), but by using the convenience helper we
#avoid to put extra methods in application and everything is easier to find.
class ContentController < ApplicationController
    include ContentPermissionsHelper rescue nil 
  before_filter :get_render_options
  
 def initialize
	begin	  
	  #fckeditor assumes the uploaded file is always tempfile, but in rails a small file is sent like StringIO
	  FckeditorController.class_eval do
      def check_file(file)    
        # check that the file is a tempfile object
        unless "#{file.class}" == "Tempfile" || "#{file.class}" == "StringIO"
          @errorNumber = 403
          throw Exception.new
        end
        file
      end
      
      def create_folder_with_svn
        if create_folder_without_svn == 0
          @url = current_directory_path
          path = @url + params[:NewFolderName]
          Content.add_path_to_svn(path)
        end        
      end
      #alias_method_chain :create_folder, :svn
      
      def upload_file_with_svn
        if upload_file_without_svn == 0
          @new_file = check_file(params[:NewFile])
          path = current_directory_path + "/" + @new_file.original_filename
          Content.add_path_to_svn(path)
        end
      end
      #alias_method_chain :upload_file, :svn
      
    end 	 
	 
	#fckeditor uses internally these constants for the file path
	FckeditorController.const_set('UPLOADED', Content.upload_path) 
	FckeditorController.const_set('UPLOADED_ROOT', RAILS_ROOT + "/public" + FckeditorController::UPLOADED)						
   rescue
   end   
 end
  
  #gets control parameters from the params hash and sets instance variables
  def get_render_options
    @page_template = params[:page_template] #if passed, no page_template combo will be displayed
    @hide_admin = params[:hide_admin] #if passed, no admin bar will be displayed
    @hide_sections = params[:hide_sections] #if passed, no sections link will be displayed
    @hide_pages = params[:hide_pages] #if passed, no pages link will be displayed
    @no_layout = params[:no_layout] #if passed, no layout will be used for displaying the page
  end
  
  #This method expects a "page_path" parameter. Default is "/". This page_path will be looked up in the
  #ContentPage model. If the page_template field is blank, it means it's not a content page, but a section
  #so the first child page (using position) of the section will be retrieved instead
  #The method is automatically called for the home of the application and for the pages starting
  #by the prefix set in the plugin routes. This behavior can be changed by setting Content.web_prefix
  #and Content.map_home_to_content variables
  def display_content_page    
    page_path = if params[:page_path].is_a?(Array)            
      params[:page_path].empty? ? '/' : params[:page_path].insert(0,nil).join('/')      
    elsif params[:page_path].is_a?(String)
      params[:page_path] 
    else
      '/'  
    end
    
    page_path.squeeze!('/')  #sometimes we get a //
    
    
    render :nothing=>true and return if page_path.nil?
    
    @obj_page = ContentPage.find_by_page_path(page_path) 
    if @obj_page && @obj_page.page_template.blank?
      @obj_page = @obj_page.child_pages.first
    end
    
    render :nothing=>true and return if @obj_page.nil?
    
    #if there is no role for the page or we are admin we display the page
    #if there is a role, we call the role method (defined in ContentRole model) to
    #check if the user can display the current page
    unless @obj_page.content_role.nil? || @obj_page.content_role.role_method.blank? || content_admin_role?
     if !(self.send(@obj_page.content_role.role_method, @obj_page) )
      render :partial=>"content/unauthorized_user" and return 
     end 
    end
    
    #we display the page template, which is a partial under content/page/templates
     render :partial=>"content/page_templates/#{@page_template.blank? ? @obj_page.page_template : @page_template}", :layout=> @no_layout ? false : 'content'
  end
  
  #displays html content edit popup
  def html_content_edit
    page_path = params[:page_path]
    area = params[:area]    
    version = params[:version] || 1
 	@editor_width=params[:editor_width]
    @editor_height=params[:editor_height]
    @obj_content = HtmlContent.get_by_page_path_and_area(page_path, area, content_language, version)    

    if @obj_content.nil? && version != 1
      redirect_to :action=>'html_content_edit', :page_path=>page_path, :area=>area, :version=>1
    else  
      render :layout=>false
    end  
  end
  
  #updates html content edit
  def html_content_update
    obj_content = if params[:obj_content][:id].blank?
      HtmlContent.new(:language=>content_language)
    else
      obj_content = HtmlContent.find_or_initialize_by_content_page_id_and_area_and_language_and_version(params[:obj_content][:content_page_id],params[:obj_content][:area],content_language,1)
    end
    b_success = obj_content.update_attributes(params[:obj_content])
    render :text=>obj_content.content
  end
  
  #displays component content edit popup
  def component_content_edit
    page_path = params[:page_path]
    area = params[:area]    
    version = params[:version] || 1    
    @obj_content = ComponentContent.get_by_page_path_and_area(page_path, area,version)    
    if @obj_content.nil? && version != 1
      redirect_to :action=>'component_content_edit', :page_path=>page_path, :area=>area, :version=>1
    else  
      render :layout=>false and return
    end  
    
    render :layout=>false
  end
  
  #updayes component content edit
  def component_content_update
    obj_content = if params[:obj_content][:id].blank?
      ComponentContent.new
    else
      obj_content = ComponentContent.find_by_content_page_id_and_area_and_version(params[:obj_content][:content_page_id],params[:obj_content][:area],1)
    end
    b_success = obj_content.update_attributes(params[:obj_content])
    render :partial=>"content/components/#{obj_content.component}/component_content"
  end
  
  
  #changes current page template and reloads to display the change
  def change_current_page_template
    obj_page=ContentPage.find(params[:page_id])
    obj_page.update_attribute('page_template',params[:page_template])
    
    render :update do |page|
      page.call 'location.reload'
    end
  end
  
  #display the pages edit popup
  def sibling_pages_edit
    @page = ContentPage.find(params[:page_id]) rescue nil  
    render :layout=>false
  end
  
  #updates the order of the pages
  def sibling_page_list_reorder    
    i_delta = params[:delta].to_i rescue 0
    parent_id = params[:parent_id]
    position = params[:position].to_i 
    
    change_page_position(parent_id, position, i_delta)
    
    @page = ContentPage.find(params[:page_id]) rescue nil
    render :partial=>'sibling_page_list', :locals=>{:page=>@page, :page_template=>@page_template, :hide_sections=>@hide_sections,:hide_pages=>@hide_pages}
  end
  
  #inserts a new page
  def sibling_page_update
    obj_parent = if (params[:parent_page_id].blank?)
      nil
    else
      ContentPage.find(params[:parent_page_id])  
    end
    
    obj_page =  params[:id].blank? ?  ContentPage.new :  ContentPage.find(params[:id])

    if params[:id].blank?    
      obj_page.position = obj_parent.nil? ? 1 : obj_parent.child_pages.size + 1      
      obj_page.content_role_id = obj_parent.nil? ? nil : obj_parent.content_role_id
    end

    obj_page.title=params[:page_name]
    obj_page.page_path = (obj_parent.nil? ? '' : (obj_parent.page_path) + '/' + params[:page_name]).squeeze('/')
    obj_page.page_template = params[:page_template]
    obj_page.parent_id = params[:parent_page_id] unless params[:parent_page_id].blank?
    if (obj_page.valid?)
      obj_page.save     
    end
    
    @sibling_page = obj_page
    @page = ContentPage.find(params[:sibling_page_id]) rescue nil

    render :partial=>'sibling_page_list', :locals=>{:page=>@page, :page_template=>@page_template, :hide_sections=>@hide_sections,:hide_pages=>@hide_pages}
  end #sibling_page_update
  
  #deletes a page
  def sibling_page_delete
    #first we move the page to last, so the order of the other pages in group is updated
    obj_page = ContentPage.find(params[:id])
    change_page_position(obj_page.parent_id, obj_page.position, obj_page.parent.child_pages.size - obj_page.position)
    #now we can delete the page without worrying about the order, since it's the last one
    ContentPage.destroy(params[:id])
    @page = ContentPage.find(params[:sibling_page_id]) rescue nil

    render :partial=>'sibling_page_list', :locals=>{:page=>@page, :page_template=>@page_template, :hide_sections=>@hide_sections,:hide_pages=>@hide_pages}
  end #sibling_page_delete
  
  #displays the section popup
  def child_sections_edit
    @page = ContentPage.find(params[:page_id]) rescue nil
    render :layout=>false
  end #child_sections_edit
  
  #updates the order of sections
  def child_section_list_reorder    
    i_delta = params[:delta].to_i rescue 0
    parent_id = params[:parent_id]
    position = params[:position].to_i 
    
    change_section_position(parent_id, position, i_delta)
    
    @page = ContentPage.find(params[:page_id]) rescue nil
    render :partial=>'child_section_list', :locals=>{:page=>@page, :page_template=>@page_template, :hide_sections=>@hide_sections,:hide_pages=>@hide_pages}
  end #child_section_list_reorder
  
  #inserts a new section
  def child_section_update
    obj_parent = if (params[:parent_page_id].blank?)
      nil
    else
      ContentPage.find(params[:parent_page_id])  
    end
    
    obj_page =  params[:id].blank? ?  ContentPage.new :  ContentPage.find(params[:id])

    if params[:id].blank?    
      obj_page.position = obj_parent.nil? ? 1 : obj_parent.child_sections.size + 1      
      obj_page.content_role_id = obj_parent.nil? ? nil : obj_parent.content_role_id
    end

	obj_page.title=params[:section_name]        
    obj_page.page_path = (obj_parent.nil? ? '' : (obj_parent.page_path) + '/' + params[:section_name]).squeeze('/')
    obj_page.page_template = params[:page_template]
    obj_page.parent_id = params[:parent_page_id] unless params[:parent_page_id].blank?
    if params[:id].blank?
      obj_index_page = ContentPage.new
      obj_index_page.page_path = obj_page.page_path + '/index'    
      obj_index_page.page_template = Content.default_template
      obj_index_page.position = 1
      obj_page.children << obj_index_page
    end
    
    if (obj_page.valid?)
      obj_page.save     
    end
    
    @child_section = obj_page
    @page = obj_page 
    render :partial=>'child_section_list', :locals=>{:page=>@page, :page_template=>@page_template, :hide_sections=>@hide_sections,:hide_pages=>@hide_pages}
  end #child_section_update

  #deletes a section
  def child_section_delete
    #first we move the page to last, so the order of the other pages in group is updated
    obj_page = ContentPage.find(params[:id])
    change_page_position(obj_page.parent_id, obj_page.position, obj_page.parent.child_sections.size - obj_page.position)
    #now we can delete the page without worrying about the order, since it's the last one
    ContentPage.destroy(params[:id])
    @page = ContentPage.find(params[:parent_id]) rescue nil
    render :partial=>'child_section_list', :locals=>{:page=>@page, :page_template=>@page_template, :hide_sections=>@hide_sections,:hide_pages=>@hide_pages}
  end #def child_section_delete

  #displays the previous page in this section. If this page has position 1 redirects to self
  def display_previous_page
    return if params[:page_path].blank?
    obj_page = ContentPage.find_by_page_path(params[:page_path])
    render :nothing and return if obj_page.blank?
    
    arr_pages = obj_page.page_siblings
    page_path= obj_page.position == 1 ? obj_page.page_path : arr_pages[obj_page.position-2].page_path rescue page_path
    
    
    redirect_to :controller=>'content', :action=>'display_content_page', :page_path=>page_path.sub(/^\//,''), :hide_admin=>@hide_admin, :page_template=>@page_template, :hide_sections=>@hide_sections,:hide_pages=>@hide_pages
    return
  end
  
  #displays the previous page in this section. If this page is the last in the section redirects to self
  def display_next_page
    return if params[:page_path].blank?
    obj_page = ContentPage.find_by_page_path(params[:page_path])
    render :nothing and return if obj_page.blank?
    
    arr_pages = obj_page.page_siblings
    position = obj_page.position == arr_pages.size ? (obj_page.position - 1) : obj_page.position
    page_path= arr_pages[position].page_path rescue page_path
    
    redirect_to :controller=>'content', :action=>'display_content_page', :page_path=>page_path.sub(/^\//,''), :hide_admin=>@hide_admin, :page_template=>@page_template, :hide_sections=>@hide_sections,:hide_pages=>@hide_pages
    return
  end
  
  def publish_dialog
    @page = ContentPage.find(params[:page_id]) rescue nil
    @last_publication=ContentPublishAction.last_publication.created_at.strftime('%Y/%m/%d %H:%M:%S') rescue ''    
    render :layout=>false
  end #publish_dialog
  
  def start_publication
    Content.publish
    render :text=>'Se ha publicado el contenido del site'
  end #start_publication

  def svn_update
    path=params[:path]
    render :text=>'No path' and return if path.blank?
    path=path[1..-1] if path.starts_with? '/'
    Dir.chdir("#{RAILS_ROOT}") do
      system "svn update #{path}"      
    end
    render :text=>'update executed'
  end
  #### private methods  
  private
  
  #updates the position for the given pages and reorders the pages in the section
  def change_page_position(parent_id, position, i_delta)
     if i_delta != 0
      ContentPage.transaction do
        curr_page = ContentPage.find_by_parent_id_and_position(parent_id,position )
        i_target_pos = position + i_delta
        if ( i_delta > 0)
          ContentPage.connection.update("update content_pages set position = position - 1 where parent_id=#{parent_id} and page_template IS NOT NULL and position > #{position} and position <= #{i_target_pos}")
        else
          ContentPage.connection.update("update content_pages set position = position + 1 where  parent_id=#{parent_id} and page_template IS NOT NULL and position < #{position} and position >= #{i_target_pos}")          
        end
        curr_page.position = i_target_pos
        curr_page.save
      end
    end     
  end #change_page_position

  #updates the position for the given section and reorders the sections in this section
  def change_section_position(parent_id, position, i_delta)
     if i_delta != 0
      ContentPage.transaction do
        curr_page = ContentPage.find_by_parent_id_and_position(parent_id,position )
        i_target_pos = position + i_delta
        if ( i_delta > 0)
          ContentPage.connection.update("update content_pages set position = position - 1 where parent_id=#{parent_id} and page_template IS NULL and position > #{position} and position <= #{i_target_pos}")
        else
          ContentPage.connection.update("update content_pages set position = position + 1 where  parent_id=#{parent_id} and page_template IS NULL and position < #{position} and position >= #{i_target_pos}")          
        end
        curr_page.position = i_target_pos
        curr_page.save
      end
    end     
  end #change_section_position
  

end
