require File.dirname(__FILE__) + '/../test_helper'

class EnterpriseTest < Test::Unit::TestCase
  def test_invalid_with_blank_attributes
    enterprise = Enterprise.new
    assert !enterprise.valid?
    assert enterprise.errors.invalid?(:name)
    assert enterprise.errors.invalid?(:alias)
  end

  def test_invalid_with_duplicated_name
    enterprise_boo = Enterprise.new :name => 'Boo', :alias => 'boo'
    enterprise_boo.save
    enterprise_bar = Enterprise.new :name => 'Boo', :alias => 'bar'
    assert !enterprise_bar.valid?
    assert enterprise_bar.errors.invalid?(:name)
    assert !enterprise_bar.errors.invalid?(:alias)
  end

  def test_invalid_with_duplicated_alias
    enterprise_boo = Enterprise.new :name => 'Boo', :alias => 'boo'
    enterprise_boo.save
    enterprise_bar = Enterprise.new :name => 'Bar', :alias => 'boo'
    assert !enterprise_bar.valid?
    assert enterprise_bar.errors.invalid?(:alias)
    assert !enterprise_bar.errors.invalid?(:name)
  end

  def test_valid_user
    enterprise = Enterprise.new :name => 'Boo', :alias => 'boo'
    assert enterprise.valid?
    assert enterprise.save
  end
end
