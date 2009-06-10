require File.dirname(__FILE__) + '/../test_helper'
require 'areas_controller'

# Re-raise errors caught by the controller.
class AreasController; def rescue_action(e) raise e end; end

class AreasControllerTest < Test::Unit::TestCase
  fixtures [:enterprises, :users, :areas, :profiles]

  def setup
    @controller = AreasController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.host = "foo.#{DOMAIN_NAME}"
  end

  def test_redirected_to_login
    logout
    post :create, :area => {:name =>'Foo'}
    assert_redirected_to :controller => 'account', :action => 'index'
  end

  def test_create_after_admin_login
    login_as_admin
    set_counts
    post :create, :area => {:name =>'New Foo', :enterprise_id => @user.enterprise_id, :owner => @user.id}
    assert_equal @enterprise_areas_count + 1, @user.enterprise.areas.count
    assert_equal @areas_count + 1, Area.count
    assert_equal @persps_count + 4, Perspective.count
  end

  def test_create_failed_with_existent_name_after_admin_login
    login_as_admin
    set_counts
    post :create, :area => {:name =>'Foo', :enterprise_id => @user.enterprise_id, :owner => @user.id}
    assert_equal @areas_count, Area.count
  end

  private

  def set_counts
    @areas_count = Area.count
    @enterprise_areas_count = @user.enterprise.areas.count
    @persps_count = Perspective.count
  end
  
  def login_as_admin
    @user = users(:foo)
    @request.session[:user] = @user.id
  end

  def logout
    @request.session[:user] = nil
  end
end
