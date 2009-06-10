require File.dirname(__FILE__) + '/../test_helper'
require 'affects_controller'

# Re-raise errors caught by the controller.
class AffectsController; def rescue_action(e) raise e end; end

class AffectsControllerTest < Test::Unit::TestCase
  fixtures [:enterprises, :users, :profiles, :areas, :perspectives, :time_units, :periods, :objectives]

  def setup
    @controller = AffectsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.host = "foo.#{DOMAIN_NAME}"
  end

  def test_redirected_to_login
    logout
    post :create, :affect => {:name =>'Foo'}
    assert_redirected_to :controller => 'account', :action => 'index'
  end

  def test_create_after_admin_login
    login_as_admin
    @objective1 = objectives(:foo)
    @objective2 = objectives(:bar)
    set_counts
    post :create, :affect => {:affecting => @objective1, :affected => @objective2}
    assert_equal @objective1_affected_count + 1, @objective1.affected_objectives.count
    assert_equal @objective2_affecting_count + 1, @objective2.affecting_objectives.count
    assert_equal @affects_count + 1, Affect.count
  end

  private

  def set_counts
    @affects_count = Affect.count
    @objective1_affected_count = @objective1.affected_objectives.count
    @objective2_affecting_count = @objective2.affecting_objectives.count
  end
  
  def login_as_admin
    @user = users(:foo)
    @request.session[:user] = @user.id
  end

  def logout
    @request.session[:user] = nil
  end
end
