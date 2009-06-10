require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end

class UsersControllerTest < Test::Unit::TestCase
  fixtures [:enterprises, :users, :profiles]

  def setup
    @controller = UsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.host = "foo.#{DOMAIN_NAME}"
  end

  def test_redirected_to_login
    logout
    post :create, :user => {:first_name =>'Foo'}
    assert_redirected_to :controller => 'account', :action => 'index'
  end

  def test_create_after_admin_login
    login_as_admin
    @enterprise = enterprises(:foo)
    set_counts
    post :create, :user => {:first_name => 'New', :last_name => 'Foo', :enterprise_id => @enterprise.id, :profile_id => profiles(:administrator).id, :email => 'newfoo@bar.com', :password => 'foofoo', :password_confirmation => 'foofoo'}
    assert_equal @enterprise_users_count + 1, @enterprise.users.count
    assert_equal @users_count + 1, User.count
  end

  def test_create_failed_with_existent_email_after_admin_login
    login_as_admin
    @enterprise = enterprises(:foo)
    set_counts
    post :create, :user => {:first_name => 'New', :last_name => 'Foo', :enterprise_id => @enterprise.id, :profile_id => profiles(:administrator).id, :email => 'foo@bar.com', :password => 'foofoo', :password_confirmation => 'foofoo'}
    assert_equal @users_count, User.count
  end

  private

  def set_counts
    @users_count = User.count
    @enterprise_users_count = @enterprise.users.count
  end
  
  def login_as_admin
    @user = users(:foo)
    @request.session[:user] = @user.id
  end

  def logout
    @request.session[:user] = nil
  end
end
