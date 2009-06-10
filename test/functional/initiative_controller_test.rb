require File.dirname(__FILE__) + '/../test_helper'
require 'initiatives_controller'

# Re-raise errors caught by the controller.
class InitiativesController; def rescue_action(e) raise e end; end

class InitiativesControllerTest < Test::Unit::TestCase
  fixtures [:enterprises, :users, :profiles, :areas, :perspectives, :time_units, :periods, :objectives]

  def setup
    @controller = InitiativesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.host = "foo.#{DOMAIN_NAME}"
  end

  def test_redirected_to_login
    logout
    post :create, :initiative => {:name =>'Foo'}
    assert_redirected_to :controller => 'account', :action => 'index'
  end

  def test_create_after_admin_login
    login_as_admin
    @objective = objectives(:foo)
    set_counts
    post :create, :initiative => {:name =>'New Foo', :description =>'This is a New Foo', :objective_id => @objective.id, :assigned_to => @user.id, :ini_date => Date.today, :end_date => Date.today + 2, :budget => 3000, :budget_attribute => 'euros'}
    assert_equal @objective_initiatives_count + 1, @objective.initiatives.count
    assert_equal @initiatives_count + 1, Initiative.count
  end

  private

  def set_counts
    @initiatives_count = Initiative.count
    @objective_initiatives_count = @objective.initiatives.count
  end
  
  def login_as_admin
    @user = users(:foo)
    @request.session[:user] = @user.id
  end

  def logout
    @request.session[:user] = nil
  end
end
