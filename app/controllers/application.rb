# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_strategygem_mor_session_id'
  filter_parameter_logging :password
  
  include ExceptionNotifiable
  include AuthenticatedSystem
  include AccountLocation

  def get_theme
    if current_user && !current_user.nil? && !current_user.enterprise.nil?
	  current_user.enterprise.css
	elsif account_subdomain != 'www' 
      enterprise = Enterprise.find_by_name(account_subdomain)
	  if !enterprise.blank?
	    enterprise.css
      else
	    'default'
	  end
	else
	  'default'
	end
  end  
end