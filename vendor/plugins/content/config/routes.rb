#to provide routing for the plugin, we map the APP home to the '/' page and 
#all the pages with a given prefix will be routed to content/display_content_page
#passing the rest of the url as the page_path parameter
#By setting Content.map_home_to_content to false, no mapping ot the APP home will be set
#By setting Content.web_prefix, the route will be mapped accordingly
module ActionController
  module Routing #:nodoc:
    class RouteSet #:nodoc:      
      def draw_with_content
        draw_without_content do |map|        
        map.connect '', :controller => 'content', :action=>'display_content_page' if Content.map_home_to_content
        map.connect "#{Content.web_prefix}/*page_path", :controller=>'content', :action=>'display_content_page'
          yield map
        end        
      end
      alias_method_chain :draw, :content
    end #routeset
  end #routing
end #actioncontroller
