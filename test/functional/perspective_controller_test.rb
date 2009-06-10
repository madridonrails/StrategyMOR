require File.dirname(__FILE__) + '/../test_helper'
require 'perspectives_controller'

# Re-raise errors caught by the controller.
class PerspectivesController; def rescue_action(e) raise e end; end

class PerspectivesControllerTest < Test::Unit::TestCase
  fixtures [:enterprises, :users, :profiles, :areas, :perspectives]

  def setup
    @controller = PerspectivesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.host = "foo.#{DOMAIN_NAME}"
  end

  def test_redirected_to_login
    logout
    post :create, :perspective => {:name =>'Foo'}
    assert_redirected_to :controller => 'account', :action => 'index'
  end

  def test_create_after_admin_login
    login_as_admin
    @area = areas(:foo)
    set_counts
    post :create, :perspective => {:name =>'New Foo', :area_id => @area.id}
    assert_equal @area_perspectives_count + 1, @area.perspectives.count
    assert_equal @perspectives_count + 1, Perspective.count
  end

  def test_create_failed_with_existent_name_after_admin_login
    login_as_admin
    @area = areas(:foo)
    set_counts
    post :create, :perspective => {:name =>'Foo', :area_id => @area.id}
    assert_equal @perspectives_count, Perspective.count
  end

  private

  def set_counts
    @perspectives_count = Perspective.count
    @area_perspectives_count = @area.perspectives.count
  end
  
  def login_as_admin
    @user = users(:foo)
    @request.session[:user] = @user.id
  end

  def logout
    @request.session[:user] = nil
  end
end
