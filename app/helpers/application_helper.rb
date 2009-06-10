# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def permission_combo(t, f)
    select(t, f, BscgemUtils::PERMISSION, {:include_blank=>false}, {:class=>"text-input", :style => 'width:200px;'}); 
  end
  
  def format_permission(p)
	BscgemUtils::PERMISSION.invert[p]
  end

  def theme_combo(t, f)
    select(t, f, Theme.find_all.collect {|t| [t.title, t.name]}, {:include_blank=>false}, {:class=>'text-input', :style => 'width:200px;'}); 
  end

  def display_flash_notice
    flash[:notice] ? %Q{<div id='notice'>#{flash[:notice]}</div>} : ''    
  end
  
  def display_flash_error
    flash[:error] ? %Q{<div id='error'>#{flash[:error]}</div>} : ''
  end
  
  #pagination
  
  # Returns the links to pages for paginated listings.
  def pagination_links_remote(options={})
    paginator = options[:paginator]
    actions = []
    1.upto(paginator.page_count) do |n|
      if paginator[n] == paginator.current_page
        actions << n.to_s
      else
        options[:url][:page] = n
        actions << link_to_remote(n.to_s, options)
      end
    end
    "[ #{actions.join(' | ')} ]"
  end

  # Returns the link to the next page for paginated listings.
  def pagination_link_next(str,options={})
    paginator = options[:paginator]
    puts "next: #{paginator}"
    actions = []
    unless paginator.current.next.nil?
        options[:url][:page] = paginator.current.next
        actions << link_to_remote(str, options)
    end
    "#{actions}"
  end

  # Returns the link to the previous page for paginated listings.
  def pagination_link_previous(str,options={})
    paginator = options[:paginator]
    actions = []
    unless paginator.current.previous.nil?
        options[:url][:page] = paginator.current.previous
        actions << link_to_remote(str, options)
    end
    "#{actions}"
  end

  # Returns the link to the first page for paginated listings.
  def pagination_link_first(str,options={})
    paginator = options[:paginator]
    actions = []
    unless paginator.current == paginator.first
        options[:url][:page] = paginator.first
        actions << link_to_remote(str, options)
    end
    "#{actions}"
  end

  # Returns the link to the previous page for paginated listings.
  def pagination_link_last(str,options={})
    paginator = options[:paginator]
    actions = []
    unless paginator.current == paginator.last
        options[:url][:page] = paginator.last
        actions << link_to_remote(str, options)
    end
    "#{actions}"
  end

  # Returns the text with the number of pages to paginate.
  def pagination_pages(options={})
    paginator = options[:paginator]    
    "P&aacute;gina #{paginator.current.number} de #{paginator.page_count}"
  end

  private
  def error_messages_for_scaffold(object_name, options = {})
    options = options.symbolize_keys
    object = instance_variable_get("@#{object_name}")
    if object && !object.errors.empty?
      content_tag("div",
        content_tag(
          options[:header_tag] || "h2",
          "#{pluralize(object.errors.count, "error")} guardando la informaci&oacute;n"
        ) +
        content_tag("p", "Los siguientes campos contienen errores:<br/><br/>") +
        content_tag("ul", object.errors.full_messages.collect { |msg| content_tag("li", msg) }),
        "id" => options[:id] || "errorExplanation", "class" => options[:class] || "errorExplanation"
      )
    else
      ""
    end
  end

  def objective_status_img(obj)
    img_status = "oo"
    if obj.status == 'ko'
      img_status = "ko"
    elsif obj.status == 'ok'
      img_status = "ok"
    end
    img_direction = "even"
	l = obj.checkpoints.length
    if l > 1
      if obj.checkpoints[l-1].value < obj.checkpoints[l-2].value
        img_direction = "down"
	  elsif obj.checkpoints[l-1].value > obj.checkpoints[l-2].value
        img_direction = "up"
	  end
	end
	
    image_tag (img_status + "_" + img_direction + ".png"), :alt => 'Estado correcto', :title => 'Correcto'
  end
end
