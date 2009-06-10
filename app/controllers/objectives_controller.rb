class ObjectivesController < ApplicationController
  include AjaxScaffold::Controller
  
  before_filter :login_required
  before_filter :update_params_filter
  after_filter :clear_flashes
  
  def update_params_filter
    update_params :default_scaffold_id => "objective", :default_sort => nil, :default_sort_direction => "asc"
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
    @sort_sql = Objective.scaffold_columns_hash[current_sort(params)].sort_sql rescue nil
    @sort_by = @sort_sql.nil? ? "#{Objective.table_name}.#{Objective.primary_key} asc" : @sort_sql  + " " + current_sort_direction(params)
    
    if !params[:which_ones].nil? && params[:which_ones] != 'all'
      if params[:which_ones] == 'mine'
        @objective_conditions = ['enterprise_id = ? AND updater = ?', current_user.enterprise_id, current_user[:id]] 
      elsif params[:which_ones] == 'pending'
      #pending
      end
    end

    @paginator, @objectives = paginate(:objectives, :order => @sort_by, :per_page => BscgemUtils::PAGE_SIZE, :include => [{:perspective => [{:area => [:enterprise]}]}], :conditions => @objective_conditions)
    
    render :action => "component", :layout => false
  end

  def new
    @objective = Objective.new
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
      @objective = Objective.new(params[:objective])
      @successful = @objective.save
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
      @objective = Objective.find(params[:id])
      @successful = !@objective.nil?
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
      @objective = Objective.find(params[:id])
      @successful = @objective.update_attributes(params[:objective])
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
      @successful = Objective.find(params[:id]).destroy
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

  def bsc_view
    begin
      @objective = Objective.find(params[:id])
      @successful = !@objective.nil?
    rescue
      flash[:error], @successful  = $!.to_s, false
    end
    
    return render(:action => 'bsc_view.rjs') if request.xhr?

    if @successful
      @options = {:id => params[:id] }
      render :partial => 'bsc_view', :layout => true
    else
      return_to_main
    end    
  end

  def bsc_cancel
    @successful = true
    
    return render(:action => 'bsc_cancel.rjs') if request.xhr?
    
    return_to_main
  end

  def bsc_new
    @objective = Objective.new
    @successful = true

    return render(:action => 'bsc_new.rjs') if request.xhr?

    # Javascript disabled fallback
    if @successful
      @options = { :action => "create" }
      render :partial => "bsc_new", :layout => true
    else 
      return_to_main
    end
  end

  def bsc_create
    @perspectives_to_repaint = Array.new
    @objectives_to_delete = Array.new
	@close_popup = true
	
    begin
      @objective = Objective.new(params[:objective])
      @successful = @objective.save
    rescue
      flash[:error], @successful  = $!.to_s, false
    end
    
    @perspectives_to_repaint << @objective.perspective
	
    return render(:action => 'bsc_objective_changed.rjs') if request.xhr?
    if @successful
      return_to_main
    end
  end

  def bsc_edit
    begin
      @objective = Objective.find(params[:id])
      @successful = !@objective.nil?
    rescue
      flash[:error], @successful  = $!.to_s, false
    end
    
    return render(:action => 'bsc_edit.rjs') if request.xhr?

    if @successful
      @options = {:action => "bsc_update", :id => params[:id] }
      render :partial => 'bsc_edit', :layout => true
    else
      return_to_main
    end    
  end

  def bsc_update
    @perspectives_to_repaint = Array.new
    @objectives_to_delete = Array.new
	@close_popup = true

	@objective = Objective.find(params[:id])
    persp_ini = @objective.perspective

    begin
      @successful = @objective.update_attributes(params[:objective])
    rescue
      flash[:error], @successful  = $!.to_s, false
    end

	obj_end = Objective.find(params[:id])
    persp_end = obj_end.perspective

    @perspectives_to_repaint << Perspective.find(persp_ini.id)
	if persp_ini.id != persp_end.id
	  @perspectives_to_repaint << Perspective.find(persp_end.id)
    end	
    
	if @successful && !params[:checkpoint].nil?
      @checkpoint = Checkpoint.new
	  @checkpoint.upper_limit = obj_end.upper_limit
      @checkpoint.lower_limit = obj_end.lower_limit
	  @checkpoint.target = obj_end.target
	  @checkpoint.value = obj_end.value
	  @checkpoint.comments = 'automatically generated'
	  #@checkpoint.update_date = params[:checkpoint][:update_date]
	  @checkpoint.update_date = params[:checkpoint]['update_date(3i)'] + '-' + params[:checkpoint]['update_date(2i)'] + '-' + params[:checkpoint]['update_date(1i)']
	  @checkpoint.updater = current_user[:id]
	  @checkpoint.objective_id = obj_end.id
	  @checkpoint.save
	end

    return render(:action => 'bsc_objective_changed.rjs') if request.xhr?

    if @successful
      return_to_main
    end
  end

  def bsc_destroy
    @perspectives_to_repaint = Array.new
    @objectives_to_delete = Array.new
	@close_popup = false
	
    obj = Objective.find(params[:id])

	begin
      @successful = obj.destroy
    rescue
      flash[:error], @successful  = $!.to_s, false
    end

	if obj.perspective.objectives.length > 1
      @objectives_to_delete << obj
    else
      @perspectives_to_repaint << Perspective.find(obj.perspective.id)
    end
    
    return render(:action => 'bsc_objective_changed.rjs') if request.xhr?

    if @successful
      return_to_main
    end
  end

  def bsc_dnd_to_perspective
    @perspectives_to_repaint = Array.new
    @objectives_to_delete = Array.new
	@close_popup = false

	o = Objective.find(params[:dnd_obj_objective_id])
    persp_ini = o.perspective
    persp_end = Perspective.find(params[:dnd_obj_perspective_id])
	before = params[:dnd_obj_before]

	begin
	  if persp_ini[:id] != persp_end[:id]
	    o.remove_from_list
        new_position = 1
		if !persp_end.objectives.empty?
          new_position += persp_end.objectives.last.position
		end
        o.perspective_id = persp_end[:id]
        o.position = new_position
        o.save
        o = Objective.find(params[:dnd_obj_objective_id])
	  end
      if(before.to_i == -1)
        o.move_to_bottom
      else
	    o_before = Objective.find(params[:dnd_obj_before])
        o.insert_at(o_before.position)
      end	
      @successful = o.save
    rescue
      flash[:error], @successful  = $!.to_s, false
    end

    @perspectives_to_repaint << Perspective.find(persp_ini[:id]) << Perspective.find(persp_end[:id])
    
    return render(:action => 'bsc_objective_changed.rjs')

    if @successful
      return_to_main
    end
  end

  def graph
	obj = Objective.find(params[:id])
    if !obj.nil? && !obj.checkpoints.empty?
      g = Gruff::Line.new (480)
      g.theme = {
        :colors => ['#00ff00', '#0000ff', '#ff0000', '#000000'],
        :marker_color => '#000000',
        :background_colors => ['#ffffff', '#dddddd']
      }
      g.font = File.expand_path('artwork/fonts/VeraBd.ttf', RAILS_ROOT)
      g.title = obj.name
      g.data("Superior", obj.checkpoints.collect{|p| p.upper_limit})
      g.data("Meta", obj.checkpoints.collect{|p| p.target})
      g.data("Inferior", obj.checkpoints.collect{|p| p.lower_limit})
      g.data("Valor", obj.checkpoints.collect{|p| p["value"]})

      g.labels = {0 => obj.checkpoints[0].formatted_update_date.to_s}
	  if obj.checkpoints.size > 1
	    g.labels.merge!(obj.checkpoints.size-1 => obj.checkpoints[obj.checkpoints.size-1].formatted_update_date.to_s)
	  end

      send_data(g.to_blob, :disposition => 'inline', :type => 'image/png', :filename => "gruff.png")
	end
  end

  def combo_by_perspective
    @objectives = Objective.find(:all, :conditions => ['perspective_id = ?', params[:combo_perspective_id]])
    return render(:partial => 'combo_by_perspective', :layout => false) if request.xhr?
 
    return_to_main
  end
end
