require File.dirname(__FILE__) + '/../test_helper'
require 'objectives_controller'

# Re-raise errors caught by the controller.
class ObjectivesController; def rescue_action(e) raise e end; end

class ObjectivesControllerTest < Test::Unit::TestCase
  fixtures [:enterprises, :users, :profiles, :areas, :perspectives, :time_units, :periods, :objectives]

  def setup
    @controller = ObjectivesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.host = "foo.#{DOMAIN_NAME}"
  end

  def test_redirected_to_login
    logout
    post :create, :objective => {:name =>'Foo'}
    assert_redirected_to :controller => 'account', :action => 'index'
  end

  def test_create_after_admin_login
    login_as_admin
    @perspective = perspectives(:foo)
    period = periods(:foo)
    set_counts
    post :create, :objective => {:name =>'New Foo', :description =>'This is a New Foo', :perspective_id => @perspective.id, :period_id => period.id, :creator => @user.id, :updater => @user.id, :lower_limit => 1, :target => 2, :upper_limit => 3, :value => 4}
    assert_equal @perspective_objectives_count + 1, @perspective.objectives.count
    assert_equal @objectives_count + 1, Objective.count
  end

  def test_create_failed_with_existent_name_after_admin_login
    login_as_admin
    @perspective = perspectives(:foo)
    set_counts
    post :create, :objective => {:name =>'Foo', :perspective_id => @perspective.id}
    assert_equal @objectives_count, Objective.count
  end

  private

  def set_counts
    @objectives_count = Objective.count
    @perspective_objectives_count = @perspective.objectives.count
  end
  
  def login_as_admin
    @user = users(:foo)
    @request.session[:user] = @user.id
  end

  def logout
    @request.session[:user] = nil
  end
end
