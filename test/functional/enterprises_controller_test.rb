require File.dirname(__FILE__) + '/../test_helper'
require 'enterprises_controller'

# Re-raise errors caught by the controller.
class EnterprisesController; def rescue_action(e) raise e end; end

class EnterprisesControllerTest < Test::Unit::TestCase
  fixtures [:enterprises, :users, :areas, :profiles]

  def setup
    @controller = EnterprisesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.host = "foo.#{DOMAIN_NAME}"
  end

  def test_redirected_to_login
    logout
    post :create, :enterprise => {:name =>'Foo'}
    assert_redirected_to :controller => 'account', :action => 'index'
  end

  def test_create_after_admin_login
    login_as_admin
    set_counts
    post :create, :enterprise => {:name =>'New Foo', :alias => 'new_foo'}
    assert_equal @enterprises_count + 1, Enterprise.count
  end

  def test_create_failed_with_existent_name_after_admin_login
    login_as_admin
    set_counts
    post :create, :enterprise => {:name =>'Foo', :alias => 'foo'}
    assert_equal @enterprises_count, Enterprise.count
  end

  private

  def set_counts
    @enterprises_count = Enterprise.count
  end
  
  def login_as_admin
    @user = users(:foo)
    @request.session[:user] = @user.id
  end

  def logout
    @request.session[:user] = nil
  end
end
