class UsersController < ApplicationController
  include AjaxScaffold::Controller
  
  before_filter :login_required
  before_filter :update_params_filter
  after_filter :clear_flashes
  
  def update_params_filter
    update_params :default_scaffold_id => "user", :default_sort => nil, :default_sort_direction => "asc"
  end
  def index
    redirect_to :action => 'list'
  end
  def return_to_main
    # If you have multiple scaffolds on the same view then you will want to change this to
    # to whatever controller/action shows all the views 
    # (ex: redirect_to :controller => 'AdminConsole', :action => 'index')
    redirect_to :action => 'list'
  end

  def list
  end
  
  # All posts to change scaffold level variables like sort values or page changes go through this action
  def component_update
    @show_wrapper = false # don't show the outer wrapper elements if we are just updating an existing scaffold 
    if request.xhr?
      # If this is an AJAX request then we just want to delegate to the component to rerender itself
      component
    else
      # If this is from a client without javascript we want to update the session parameters and then delegate
      # back to whatever page is displaying the scaffold, which will then rerender all scaffolds with these update parameters
      return_to_main
    end
    end

  def component  
    @show_wrapper = true if @show_wrapper.nil?
    @sort_sql = User.scaffold_columns_hash[current_sort(params)].sort_sql rescue nil
    @sort_by = @sort_sql.nil? ? "#{User.table_name}.#{User.primary_key} asc" : @sort_sql  + " " + current_sort_direction(params)
	
    @paginator, @users = paginate(:users, :order => @sort_by, :per_page => BscgemUtils::PAGE_SIZE, :conditions => @user_conditions)
    
    render :action => "component", :layout => false
  end

  def new
    @user = User.new
    @successful = true

    return render(:action => 'new.rjs') if request.xhr?

    # Javascript disabled fallback
    if @successful
      @options = { :action => "create" }
      render :partial => "new_edit", :layout => true
    else 
      return_to_main
    end
  end
  
  def create
    begin
      @user = User.new(params[:user])
      logger.info @user.inspect
      logger.info @user.enterprise.inspect
      @successful = @user.save
    rescue
      flash[:error], @successful  = $!.to_s, false
    end
    
    return render(:action => 'create.rjs') if request.xhr?
    if @successful
      return_to_main
    else
      @options = { :scaffold_id => params[:scaffold_id], :action => "create" }
      render :partial => 'new_edit', :layout => true
    end
  end

  def edit
    begin
      @user = User.find(params[:id])
      @successful = !@user.nil?
    rescue
      flash[:error], @successful  = $!.to_s, false
    end
    
    return render(:action => 'edit.rjs') if request.xhr?

    if @successful
      @options = { :scaffold_id => params[:scaffold_id], :action => "update", :id => params[:id] }
      render :partial => 'new_edit', :layout => true
    else
      return_to_main
    end    
  end

  def update
    begin
      @user = User.find(params[:id])
      @successful = @user.update_attributes(params[:user])
    rescue
      flash[:error], @successful  = $!.to_s, false
    end
    
    return render(:action => 'update.rjs') if request.xhr?

    if @successful
      return_to_main
    else
      @options = { :action => "update" }
      render :partial => 'new_edit', :layout => true
    end
  end

  def destroy
    begin
      @successful = User.find(params[:id]).destroy
    rescue
      flash[:error], @successful  = $!.to_s, false
    end
    
    return render(:action => 'destroy.rjs') if request.xhr?
    
    # Javascript disabled fallback
    return_to_main
  end
  
  def cancel
    @successful = true
    
    return render(:action => 'cancel.rjs') if request.xhr?
    
    return_to_main
  end

  def combo_by_enterprise
    @users = User.find(:all, :conditions => ['enterprise_id = ?', params[:combo_enterprise_id]])
    return render(:partial => 'combo_by_enterprise', :layout => false) if request.xhr?
 
    return_to_main
  end

  def combo_by_enterprise_and_privilege
#    @users = User.find(:all, :conditions => ['enterprise_id = ?', ])
#    @users = User.find(:all, :conditions => ["enterprise_id = ? and privilege#{privilege} in ('#{privilege_values.join('\',\'')}')", params[:combo_enterprise_id]], :include => [:profile])
    @users = User.find_by_enterprise_and_privilege(params[:combo_enterprise_id], params[:select_privilege], params[:select_privilege_values])
    return render(:partial => 'combo_by_enterprise', :layout => false) if request.xhr?
 
    return_to_main
  end

  def my_user
    begin
      @user = current_user
    rescue
      flash[:error], @successful  = $!.to_s, false
    end
    
    @options = { :scaffold_id => params[:scaffold_id], :action => "update", :id => params[:id] }
    render :partial => 'new_edit', :layout => true
  end
end
