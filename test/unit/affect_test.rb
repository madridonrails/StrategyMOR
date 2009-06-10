require File.dirname(__FILE__) + '/../test_helper'

class AffectTest < Test::Unit::TestCase
  fixtures [:enterprises, :users, :areas, :perspectives, :periods, :objectives]

  def test_invalid_with_blank_attributes
    affect = Affect.new
    assert !affect.valid?
    assert affect.errors.invalid?(:affects)
    assert affect.errors.invalid?(:affecting)
    assert affect.errors.invalid?(:is_affected)
    assert affect.errors.invalid?(:affected)
  end

  def test_invalid_with_inexistent_objectives
    affect = Affect.new
    affect.affects = 50000
    affect.is_affected = 50000
    affect.save
    assert !affect.errors.invalid?(:affects)
    assert affect.errors.invalid?(:affecting)
    assert !affect.errors.invalid?(:is_affected)
    assert affect.errors.invalid?(:affected)
  end

  def test_invalid_with_duplicated_objectives
    affecttt = Affect.new
    affecttt.affecting = objectives(:foo)
    affecttt.affected = objectives(:bar)
    affecttt.save
    affect = Affect.new
    affect.affecting = objectives(:foo)
    affect.affected = objectives(:bar)
    assert !affect.errors.invalid?(:affects)
    assert !affect.errors.invalid?(:affecting)
    assert !affect.errors.invalid?(:is_affected)
    assert !affect.errors.invalid?(:affected)
  end

  def test_valid_affect
    affect = Affect.new
    affect.affecting = objectives(:foo)
    affect.affected = objectives(:bar)
    affect.save
    assert affect.valid?
    assert affect.save
  end
end
