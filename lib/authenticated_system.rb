module AuthenticatedSystem
  protected
    # Returns true or false if the user is logged in.
    # Preloads @current_user with the user model if they're logged in.
    def logged_in?
      (@current_user ||= session[:user] ? User.find_by_id(session[:user]) : :false).is_a?(User)
    end
    
    # Accesses the current user from the session.
    def current_user
      @current_user if logged_in?
    end
    
    # Store the given user in the session.
    def current_user=(new_user)
      session[:user] = (new_user.nil? || new_user.is_a?(Symbol)) ? nil : new_user.id
      @current_user = new_user
    end
    
    # Check if the user is authorized.
    #
    # Override this method in your controllers if you want to restrict access
    # to only a few actions or if you want to check if the user
    # has the correct rights.
    #
    # Example:
    #
    #  # only allow nonbobs
    #  def authorize?
    #    current_user.login != "bob"
    #  end
    def authorized_for_enterprises
      aut = true
      if params[:controller] == 'enterprises'
        if params[:action] == 'logo'
          aut = true
        elsif current_user.profile.privilege1 == 'X'
          aut = true		
        elsif current_user.profile.privilege1 == 'U'
          if (params[:action] == 'edit' && params[:id] == current_user.enterprise[:id].to_s) || (params[:action] == 'update' && params[:id] == current_user.enterprise[:id].to_s)
            aut = true
          elsif params[:action] == 'my_enterprise' || params[:action] == 'index' || params[:action] == 'list' || params[:action].include?('component')
            @enterprise_conditions = ['id = ?', current_user.enterprise[:id]]
            aut = true
          else
            aut = false
          end
        else
          aut = false
        end
      end
      return aut
    end

    def authorized_for_periods
      aut = true
      if params[:controller] == 'periods'
        aut = true if current_user.profile.privilege3 == 'X'
      end
      return aut
    end

    def authorized_for_users
      aut = true
      if params[:controller] == 'users'
        if current_user.profile.privilege4 == 'X'
          @user_conditions = nil
          aut = true		
        elsif current_user.profile.privilege4 == 'E'
          if params[:action] == 'edit' || params[:action] == 'destroy'
            u = User.find(params[:id])
            if u.enterprise_id == current_user.enterprise[:id]
              aut = true
            else
              aut = false
            end
          elsif (params[:action] == 'create' || params[:action] == 'update') && params[:user][:enterprise_id] == current_user.enterprise[:id].to_s
            aut = true
          elsif params[:action] == 'index' || params[:action] == 'list' || params[:action] == 'component' || params[:action] == 'component_update'
            @user_conditions = ['enterprise_id = ?', current_user.enterprise_id] 
            aut = true
          elsif params[:action] == 'new'
            aut = true
          else
            aut = false
          end
        elsif current_user.profile.privilege4 == 'U'
          if (params[:action] == 'edit' && params[:id] == current_user[:id].to_s) ||( params[:action] == 'update' && params[:user][:id] == current_user[:id].to_s) 
            aut = true
          elsif params[:action] == 'my_user' || params[:action] == 'index' || params[:action] == 'list' || params[:action] == 'component' || params[:action] == 'component_update'
            @user_conditions = ['id = ?', current_user.id] 
            aut = true
          else
            aut = false
          end
        else
          aut = false
        end
      end
      return aut
    end

    def authorized_for_areas
      aut = true
      if params[:controller] == 'areas'
        if current_user.profile.privilege5 == 'X'
          aut = true		
        elsif current_user.profile.privilege5 == 'E'
          if params[:action] == 'edit' || params[:action] == 'destroy'
            a = Area.find(params[:id])
            if a.enterprise_id == current_user.enterprise[:id]
              aut = true
            else
              aut = false
            end
          elsif (params[:action] == 'update' || params[:action] == 'create') && params[:area][:enterprise_id] == current_user.enterprise_id.to_s
            aut = true
          elsif params[:action] == 'index' || params[:action] == 'list' || params[:action] == 'component' || params[:action] == 'component_update'
            @area_conditions = ['enterprise_id = ?', current_user.enterprise_id] 
            aut = true
          elsif params[:action] == 'new'
            aut = true
          else
            aut = false
          end
        elsif current_user.profile.privilege5 == 'U'
          if params[:action] == 'edit'
            a = Area.find(params[:id])
            if a.owner == current_user[:id]
              aut = true
            else
              aut = false
            end
          elsif params[:action] == 'update' && params[:enterprise_id] == current_user.enterprise[:id].to_s && params[:area][:owner] == current_user[:id].to_s
            aut = true
          elsif params[:action] == 'index' || params[:action] == 'list' || params[:action] == 'component' || params[:action] == 'component_update'
            @area_conditions = ['enterprise_id = ? AND owner = ?', current_user.enterprise_id, current_user[:id]] 
            aut = true
          else
            aut = false
          end
        else
          aut = false
        end
      end
      return aut
    end

    def authorized_for_perspectives
      aut = true
      if params[:controller] == 'perspectives'
        if current_user.profile.privilege5 == 'X'
          aut = true		
        elsif current_user.profile.privilege5 == 'E'
          if params[:action] == 'edit' || params[:action] == 'destroy'
            p = Perspective.find(params[:id])
            if p.area.enterprise_id == current_user.enterprise[:id]
              aut = true
            else
              aut = false
            end
          elsif (params[:action] == 'update' || params[:action] == 'create') 
            a = Area.find(params[:perspective][:area_id])
            if a.enterprise_id == current_user.enterprise_id
              aut = true
            else
              aut = false
            end
          elsif params[:action] == 'index' || params[:action] == 'list' || params[:action] == 'component' || params[:action] == 'component_update'
            @perspective_conditions = ['enterprise_id = ?', current_user.enterprise_id] 
            aut = true
          elsif params[:action] == 'new'
            aut = true
          else
            aut = false
          end
        elsif current_user.profile.privilege5 == 'A'
          if params[:action] == 'edit' || params[:action] == 'destroy'
            p = Perspective.find(params[:id])
            if p.area.owner == current_user[:id]
              aut = true
            else
              aut = false
            end
          elsif (params[:action] == 'update' || params[:action] == 'create') 
            a = Area.find(params[:perspective][:area_id])
            if a.enterprise_id == current_user.enterprise_id && a.owner == current_user[:id]
              aut = true
            else
              aut = false
            end
          elsif params[:action] == 'index' || params[:action] == 'list' || params[:action] == 'component' || params[:action] == 'component_update'
            @perspective_conditions = ['enterprise_id = ? AND owner = ?', current_user.enterprise_id, current_user[:id]] 
            aut = true
          elsif params[:action] == 'new'
            aut = true
          else
            aut = false
          end
        else
          aut = false
        end
      end
      return aut
    end

    def authorized_for_affects
      aut = true
      if params[:controller] == 'affects'
        if current_user.profile.privilege5 == 'X'
          aut = true		
        elsif current_user.profile.privilege5 == 'E'
          if params[:action] == 'edit' || params[:action] == 'destroy'
            a = Affect.find(params[:id])
            if a.affected.perspective.area.enterprise_id == current_user.enterprise[:id]
              aut = true
            else
              aut = false
            end
          elsif (params[:action] == 'update' || params[:action] == 'create') 
            o = Objective.find(params[:affect][:is_affected])
            if o.perspective.area.enterprise_id == current_user.enterprise_id
              aut = true
            else
              aut = false
            end
          elsif params[:action] == 'index' || params[:action] == 'list' || params[:action] == 'component' || params[:action] == 'component_update'
            @affect_conditions = ['enterprise_id = ?', current_user.enterprise_id] 
            aut = true
          elsif params[:action] == 'new'
            aut = true
          else
            aut = false
          end
        elsif current_user.profile.privilege5 == 'A'
          if params[:action] == 'edit' || params[:action] == 'destroy'
            a = Affect.find(params[:id])
            if a.affected.perspective.area.owner == current_user[:id] || a.affected.updater == current_user[:id] 
              aut = true
            else
              aut = false
            end
          elsif (params[:action] == 'update' || params[:action] == 'create') 
            o = Objective.find(params[:affect][:is_affected])
            if o.perspective.area.enterprise_id == current_user.enterprise_id && (o.perspective.area.owner == current_user[:id] || o.updater == current_user[:id])
              aut = true
            else
              aut = false
            end
          elsif params[:action] == 'index' || params[:action] == 'list' || params[:action] == 'component' || params[:action] == 'component_update'
            @affect_conditions = ['enterprise_id = ? AND (owner = ? OR updater = ?)', current_user.enterprise_id, current_user[:id], current_user[:id]] 
            aut = true
          elsif params[:action] == 'new'
            aut = true
          else
            aut = false
          end
        elsif current_user.profile.privilege6 == 'O'
          if params[:action] == 'index' || params[:action] == 'list' || params[:action] == 'component' || params[:action] == 'component_update'
            @initiative_conditions = ['enterprise_id = ? AND updater = ?', current_user.enterprise_id, current_user[:id]] 
            aut = true
          else
            aut = false
          end
        else
          aut = false
        end
      end
      return aut
    end

    def authorized_for_objectives
      aut = true
      if params[:controller] == 'objectives'
        if current_user.profile.privilege6 == 'X'
          aut = true		
        elsif current_user.profile.privilege6 == 'E'
          if params[:action] == 'edit' || params[:action] == 'destroy'
            o = Objective.find(params[:id])
            if o.perspective.area.enterprise_id == current_user.enterprise[:id]
              aut = true
            else
              aut = false
            end
          elsif (params[:action] == 'update' || params[:action] == 'create') 
            p = Perspective.find(params[:objective][:perspective_id])
            if p.area.enterprise_id == current_user.enterprise_id
              aut = true
            else
              aut = false
            end
          elsif params[:action] == 'index' || params[:action] == 'list' || params[:action] == 'component' || params[:action] == 'component_update'
            @objective_conditions = ['enterprise_id = ?', current_user.enterprise_id] 
            aut = true
          elsif params[:action] == 'new'
            aut = true
          else
            aut = false
          end
        elsif current_user.profile.privilege6 == 'A'
          if params[:action] == 'edit' || params[:action] == 'destroy'
            o = Objective.find(params[:id])
            if o.perspective.area.owner == current_user[:id] || o.updater ==  current_user[:id]
              aut = true
            else
              aut = false
            end
          elsif (params[:action] == 'update' || params[:action] == 'create') 
            p = Perspective.find(params[:objective][:perspective_id])
            o = Objective.find(params[:id])
            if p.area.enterprise_id == current_user.enterprise_id && (p.area.owner == current_user[:id] || o.updater ==  current_user[:id])
              aut = true
            else
              aut = false
            end
          elsif params[:action] == 'index' || params[:action] == 'list' || params[:action] == 'component' || params[:action] == 'component_update'
            @objective_conditions = ['enterprise_id = ? AND (owner = ? OR updater = ?)', current_user.enterprise_id, current_user[:id], current_user[:id]] 
            aut = true
          elsif params[:action] == 'new'
            aut = true
          else
            aut = false
          end
        elsif current_user.profile.privilege6 == 'U'
          if params[:action] == 'edit' || params[:action] == 'update'
            o = Objective.find(params[:id])
            if a.updater == current_user[:id]
              aut = true
            else
              aut = false
            end
          elsif params[:action] == 'index' || params[:action] == 'list' || params[:action] == 'component' || params[:action] == 'component_update'
            @objective_conditions = ['enterprise_id = ? AND updater = ?', current_user.enterprise_id, current_user[:id]] 
            aut = true
          else
            aut = false
          end
        else
          aut = false
        end
      end
      return aut
    end

    def authorized_for_checkpoints
      aut = true
      if params[:controller] == 'checkpoints'
        if current_user.profile.privilege6 == 'X'
          aut = true		
        elsif current_user.profile.privilege6 == 'E'
          if params[:action] == 'edit' || params[:action] == 'destroy'
            c = Checkpoint.find(params[:id])
            if c.objective.perspective.area.enterprise_id == current_user.enterprise[:id]
              aut = true
            else
              aut = false
            end
          elsif (params[:action] == 'update' || params[:action] == 'create') 
            o = Objective.find(params[:checkpoint][:objective_id])
            if o.perspective.area.enterprise_id == current_user.enterprise_id
              aut = true
            else
              aut = false
            end
          elsif params[:action] == 'index' || params[:action] == 'list' || params[:action] == 'component' || params[:action] == 'component_update'
            @checkpoint_conditions = ['enterprise_id = ?', current_user.enterprise_id] 
            aut = true
          elsif params[:action] == 'new'
            aut = true
          else
            aut = false
          end
        elsif current_user.profile.privilege6 == 'A'
          if params[:action] == 'edit' || params[:action] == 'destroy'
            c = Checkpoint.find(params[:id])
            if c.objective.perspective.area.owner == current_user[:id] || c.objective.updater == current_user[:id]
              aut = true
            else
              aut = false
            end
          elsif (params[:action] == 'update' || params[:action] == 'create') 
            o = Objective.find(params[:checkpoint][:objective_id])
            if o.perspective.area.enterprise_id == current_user.enterprise_id && (o.perspective.area.owner == current_user[:id] || o.updater ==  current_user[:id])
              aut = true
            else
              aut = false
            end
          elsif params[:action] == 'index' || params[:action] == 'list' || params[:action] == 'component' || params[:action] == 'component_update'
            @checkpoint_conditions = ['enterprise_id = ? AND (owner = ? OR objectives.updater = ?)', current_user.enterprise_id, current_user[:id], current_user[:id]] 
            aut = true
          elsif params[:action] == 'new'
            aut = true
          else
            aut = false
          end
        elsif current_user.profile.privilege6 == 'O'
          if params[:action] == 'edit' || params[:action] == 'destroy'
            c = Checkpoint.find(params[:id])
            if c.objective.updater == current_user[:id]
              aut = true
            else
              aut = false
            end
          elsif (params[:action] == 'update' || params[:action] == 'create') 
            o = Objective.find(params[:checkpoint][:objective_id])
            if o.perspective.area.enterprise_id == current_user.enterprise_id && o.updater ==  current_user[:id]
              aut = true
            else
              aut = false
            end
          elsif params[:action] == 'index' || params[:action] == 'list' || params[:action] == 'component' || params[:action] == 'component_update'
            @checkpoint_conditions = ['enterprise_id = ? AND objectives.updater = ?', current_user.enterprise_id, current_user[:id]] 
            aut = true
          elsif params[:action] == 'new'
            aut = true
          else
            aut = false
          end
        else
          aut = false
        end
      end
      return aut
    end

    def authorized_for_initiatives
      aut = true
      if params[:controller] == 'initiatives' 
        if current_user.profile.privilege7 == 'X'
          aut = true		
        elsif current_user.profile.privilege7 == 'E'
          if params[:action] == 'edit' || params[:action] == 'destroy'
            i = Inititative.find(params[:id])
            if i.objective.perspective.area.enterprise_id == current_user.enterprise[:id]
              aut = true
            else
              aut = false
            end
          elsif (params[:action] == 'update' || params[:action] == 'create') 
            o = Objective.find(params[:initiative][:objective_id])
            if o.perspective.area.enterprise_id == current_user.enterprise_id
              aut = true
            else
              aut = false
            end
          elsif params[:action] == 'index' || params[:action] == 'list' || params[:action] == 'component' || params[:action] == 'component_update'
            @initiative_conditions = ['enterprise_id = ?', current_user.enterprise_id] 
            aut = true
          elsif params[:action] == 'new'
            aut = true
          else
            aut = false
          end
        elsif current_user.profile.privilege7 == 'A'
          if params[:action] == 'edit' || params[:action] == 'destroy'
            i = Initiative.find(params[:id])
            if i.objective.perspective.area.owner == current_user[:id] || i.objective.updater == current_user[:id] || i.assigned_to == current_user[:id]
              aut = true
            else
              aut = false
            end
          elsif (params[:action] == 'update' || params[:action] == 'create') 
            o = Objective.find(params[:initiative][:objective_id])
            i = Initiative.find(params[:id])
            if o.perspective.area.enterprise_id == current_user.enterprise_id && (o.perspective.area.owner == current_user[:id] || o.updater ==  current_user[:id] || i.assigned_to == current_user[:id])
              aut = true
            else
              aut = false
            end
          elsif params[:action] == 'index' || params[:action] == 'list' || params[:action] == 'component' || params[:action] == 'component_update'
            @initiative_conditions = ['enterprise_id = ? AND (owner = ? OR updater = ? OR assigned_to = ?)', current_user.enterprise_id, current_user[:id], current_user[:id], current_user[:id]] 
            aut = true
          elsif params[:action] == 'new'
            aut = true
          else
            aut = false
          end
        elsif current_user.profile.privilege7 == 'O'
          if params[:action] == 'edit' || params[:action] == 'destroy'
            i = Initiative.find(params[:id])
            if i.objective.updater == current_user[:id] || i.assigned_to == current_user[:id]
              aut = true
            else
              aut = false
            end
          elsif (params[:action] == 'update' || params[:action] == 'create') 
            o = Objective.find(params[:initiative][:objective_id])
            i = Initiative.find(params[:id])
            if o.perspective.area.enterprise_id == current_user.enterprise_id && (o.updater ==  current_user[:id] || i.assigned_to == current_user[:id])
              aut = true
            else
              aut = false
            end
          elsif params[:action] == 'index' || params[:action] == 'list' || params[:action] == 'component' || params[:action] == 'component_update'
            @initiative_conditions = ['enterprise_id = ? AND (updater = ? OR assigned_to = ?)', current_user.enterprise_id, current_user[:id], current_user[:id]] 
            aut = true
          elsif params[:action] == 'new'
            aut = true
          else
            aut = false
          end
        else
          aut = false
        end
      end
      return aut
    end
    
    def authorized?
      aut = false
      aut = true if params[:action] == 'cancel'
      if !aut
        if params[:action].include? 'bsc'
          if params[:controller] == 'areas'
            if current_user.profile.privilege5 == 'X'
              aut = true
            elsif current_user.profile.privilege5 == 'E'
              a = Area.find(params[:id])
              if a.enterprise_id == current_user.enterprise_id
                aut = true
              else
                aut = false
              end
            elsif current_user.profile.privilege5 == 'A'
              a = Area.find(params[:id])
              if a.owner == current_user[:id]
                aut = true
              else
                aut = false
              end
            else
              aut = false
            end
          else
            aut = true
          end
        elsif params[:action] == 'graph'
          aut = true
        else
          logger.info "PERMISSIONS #{authorized_for_enterprises} && #{authorized_for_periods} && #{authorized_for_users} && #{authorized_for_areas} && #{authorized_for_perspectives} && #{authorized_for_affects} && #{authorized_for_objectives} && #{authorized_for_checkpoints} && #{authorized_for_initiatives}"
          aut = authorized_for_enterprises && authorized_for_periods && authorized_for_users && authorized_for_areas && authorized_for_perspectives && authorized_for_affects && authorized_for_objectives && authorized_for_checkpoints && authorized_for_initiatives
    	  end
      end
	  
      if !aut
        #pdte. redirect
        return false
      else
        return true
      end
    end

    # Filter method to enforce a login requirement.
    #
    # To require logins for all actions, use this in your controllers:
    #
    #   before_filter :login_required
    #
    # To require logins for specific actions, use this in your controllers:
    #
    #   before_filter :login_required, :only => [ :edit, :update ]
    #
    # To skip this in a subclassed controller:
    #
    #   skip_before_filter :login_required
    #
    def login_required
      username, passwd = get_auth_data
      self.current_user ||= User.authenticate(username, passwd) || :false if username && passwd
      logged_in? && authorized? ? true : access_denied
    end
    
    # Redirect as appropriate when an access request fails.
    #
    # The default action is to redirect to the login screen.
    #
    # Override this method in your controllers if you want to have special
    # behavior in case the user is not authorized
    # to access the requested action.  For example, a popup window might
    # simply close itself.
    def access_denied
      respond_to do |accepts|
        accepts.html do
          store_location
          redirect_to :controller => '/account', :action => 'index'
        end
        accepts.xml do
          headers["Status"]           = "Unauthorized"
          headers["WWW-Authenticate"] = %(Basic realm="Web Password")
          render :text => "Could't authenticate you", :status => '401 Unauthorized'
        end
      end
      return false
    end  
    
    # Store the URI of the current request in the session.
    #
    # We can return to this location by calling #redirect_back_or_default.
    def store_location
      session[:return_to] = request.request_uri
    end
    
    # Redirect to the URI stored by the most recent store_location call or
    # to the passed default.
    def redirect_back_or_default(default)
      session[:return_to] ? redirect_to_url(session[:return_to]) : redirect_to(default)
      session[:return_to] = nil
    end
    
    # Inclusion hook to make #current_user and #logged_in?
    # available as ActionView helper methods.
    def self.included(base)
      base.send :helper_method, :current_user, :logged_in?
    end

    # When called with before_filter :login_from_cookie will check for an :auth_token
    # cookie and log the user back in if apropriate
    def login_from_cookie
      return unless cookies[:auth_token] && !logged_in?
      user = User.find_by_remember_token(cookies[:auth_token])
      if user && user.remember_token?
        user.remember_me
        self.current_user = user
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
        flash[:notice] = "Logged in successfully"
      end
    end

  private
    # gets BASIC auth info
    def get_auth_data
      user, pass = nil, nil
      # extract authorisation credentials 
      if request.env.has_key? 'X-HTTP_AUTHORIZATION' 
        # try to get it where mod_rewrite might have put it 
        authdata = request.env['X-HTTP_AUTHORIZATION'].to_s.split 
      elsif request.env.has_key? 'HTTP_AUTHORIZATION' 
        # this is the regular location 
        authdata = request.env['HTTP_AUTHORIZATION'].to_s.split  
      end 
       
      # at the moment we only support basic authentication 
      if authdata && authdata[0] == 'Basic' 
        user, pass = Base64.decode64(authdata[1]).split(':')[0..1] 
      end 
      return [user, pass] 
    end
end
