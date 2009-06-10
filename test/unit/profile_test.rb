require File.dirname(__FILE__) + '/../test_helper'

class ProfileTest < Test::Unit::TestCase
  def test_invalid_with_blank_attributes
    profile = Profile.new
    assert !profile.valid?
    assert profile.errors.invalid?(:name)
    assert !profile.errors.invalid?(:privilege1) #default is 'N'
    assert !profile.errors.invalid?(:privilege2)
    assert !profile.errors.invalid?(:privilege3)
    assert !profile.errors.invalid?(:privilege4)
    assert !profile.errors.invalid?(:privilege5)
    assert !profile.errors.invalid?(:privilege6)
    assert !profile.errors.invalid?(:privilege7)
  end

  def test_invalid_with_duplicated_name
    profile_boo = new_profile('Boo')
    profile_boo.save
    profile_bar = new_profile('Boo')
    assert !profile_bar.valid?
    assert profile_bar.errors.invalid?(:name)
    assert !profile_bar.errors.invalid?(:privilege1)
    assert !profile_bar.errors.invalid?(:privilege2)
    assert !profile_bar.errors.invalid?(:privilege3)
    assert !profile_bar.errors.invalid?(:privilege4)
    assert !profile_bar.errors.invalid?(:privilege5)
    assert !profile_bar.errors.invalid?(:privilege6)
    assert !profile_bar.errors.invalid?(:privilege7)
  end

  def test_valid_profile
    profile = new_profile('Boo')
    assert profile.valid?
    assert profile.save
  end
  
  private
  def new_profile(name)
    Profile.new :name => name
  end
end
