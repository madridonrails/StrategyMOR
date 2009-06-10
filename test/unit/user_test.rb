require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  fixtures [:enterprises, :profiles]

  def test_invalid_with_blank_attributes
    user = User.new
    assert !user.valid?
    assert user.errors.invalid?(:first_name)
    assert user.errors.invalid?(:last_name)
    assert user.errors.invalid?(:password)
    assert user.errors.invalid?(:password_confirmation)
    assert user.errors.invalid?(:email)
    assert user.errors.invalid?(:enterprise_id)
    assert user.errors.invalid?(:enterprise)
    assert user.errors.invalid?(:profile_id)
    assert user.errors.invalid?(:profile)
  end

  def test_invalid_with_used_email
    @enterprise = enterprises(:foo)
    @profile = profiles(:administrator)
    user_baz = new_user_baz
    user_baz.email = 'baz@baz.com'
    user_baz.enterprise = @enterprise
    user_baz.profile = @profile
    user_baz.save
    user = new_user_coz
    user.email = user_baz.email
    user.enterprise = @enterprise
    user.profile = @profile
    assert !user.valid?
    assert !user.errors.invalid?(:first_name)
    assert !user.errors.invalid?(:last_name)
    assert !user.errors.invalid?(:password)
    assert !user.errors.invalid?(:password_confirmation)
    assert user.errors.invalid?(:email)
    assert !user.errors.invalid?(:enterprise_id)
    assert !user.errors.invalid?(:enterprise)
    assert !user.errors.invalid?(:profile_id)
    assert !user.errors.invalid?(:profile)
  end
  
  def test_invalid_with_inexistent_enterprise_and_profile
    user = new_user_baz
    user.email = 'baz@baz.com'
    user.enterprise_id = 10000
    user.profile_id = 20000
    assert !user.valid?
    assert !user.errors.invalid?(:first_name)
    assert !user.errors.invalid?(:last_name)
    assert !user.errors.invalid?(:password)
    assert !user.errors.invalid?(:password_confirmation)
    assert !user.errors.invalid?(:email)
    assert !user.errors.invalid?(:enterprise_id)
    assert user.errors.invalid?(:enterprise)
    assert !user.errors.invalid?(:profile_id)
    assert user.errors.invalid?(:profile)
  end

  def test_valid_user
    @enterprise = enterprises(:foo)
    @profile = profiles(:administrator)
    user = new_user_baz
    user.email = 'baz@baz.com'
    user.enterprise = @enterprise
    user.profile = @profile
    assert user.valid?
    assert user.save
  end

  private
  
  def new_user_baz
    User.new :first_name => 'Baz', :last_name => 'Baz', 
      :password => 'bazbaz', :password_confirmation => 'bazbaz'
  end

  def new_user_coz
    User.new :first_name => 'Coz', :last_name => 'Coz', 
      :password => 'cozcoz', :password_confirmation => 'cozcoz'
  end
end
