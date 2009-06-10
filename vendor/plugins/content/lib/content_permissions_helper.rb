module ContentPermissionsHelper
	def content_admin_role?(page=nil)
		return true if current_user && current_user.profile_id == BscgemUtils.profile('master')
	end
	
	def content_language    
    Content.default_language   
  end
end
