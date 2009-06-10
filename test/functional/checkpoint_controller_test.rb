require File.dirname(__FILE__) + '/../test_helper'
require 'checkpoints_controller'

# Re-raise errors caught by the controller.
class CheckpointsController; def rescue_action(e) raise e end; end

class CheckpointsControllerTest < Test::Unit::TestCase
  fixtures [:enterprises, :users, :profiles, :areas, :perspectives, :time_units, :periods, :objectives]

  def setup
    @controller = CheckpointsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.host = "foo.#{DOMAIN_NAME}"
  end

  def test_redirected_to_login
    logout
    post :create, :checkpoint => {:name =>'Foo'}
    assert_redirected_to :controller => 'account', :action => 'index'
  end

  def test_create_after_admin_login
    login_as_admin
    @objective = objectives(:foo)
    set_counts
    post :create, :checkpoint => {:comments => 'This is a New Foo', :update_date => Date.today, :lower_limit => 1, :target => 2, :upper_limit => 3, :value => 4, :objective_id => @objective.id, :updater => @user.id}
    assert_equal @objective_checkpoints_count + 1, @objective.checkpoints.count
    assert_equal @checkpoints_count + 1, Checkpoint.count
  end

  private

  def set_counts
    @checkpoints_count = Checkpoint.count
    @objective_checkpoints_count = @objective.checkpoints.count
  end
  
  def login_as_admin
    @user = users(:foo)
    @request.session[:user] = @user.id
  end

  def logout
    @request.session[:user] = nil
  end
end
