require File.dirname(__FILE__) + '/../test_helper'

class ObjectiveTest < Test::Unit::TestCase
  fixtures [:enterprises, :users, :areas, :perspectives, :periods]

  def test_invalid_with_blank_attributes
    obj = Objective.new
    assert !obj.valid?
    assert obj.errors.invalid?(:name)
    assert obj.errors.invalid?(:description)
    assert obj.errors.invalid?(:perspective_id)
    assert obj.errors.invalid?(:perspective)
    assert obj.errors.invalid?(:period_id)
    assert obj.errors.invalid?(:period)
    assert obj.errors.invalid?(:creator)
    assert obj.errors.invalid?(:created_by)
    assert obj.errors.invalid?(:updater)
    assert obj.errors.invalid?(:updated_by)
    assert obj.errors.invalid?(:target)
    assert obj.errors.invalid?(:value)
    assert obj.errors.invalid?(:upper_limit)
    assert obj.errors.invalid?(:lower_limit)
  end

  def test_invalid_with_inexistent_perspective_and_updater_and_creator_and_period
    obj = new_objective
    obj.perspective_id = 50000
    obj.creator = 50000
    obj.updater = 50000
    obj.period_id = 50000
    obj.save
    assert !obj.valid?
    assert !obj.errors.invalid?(:name)
    assert !obj.errors.invalid?(:description)
    assert !obj.errors.invalid?(:taget)
    assert !obj.errors.invalid?(:value)
    assert !obj.errors.invalid?(:upper_limit)
    assert !obj.errors.invalid?(:lower_limit)
    assert !obj.errors.invalid?(:perspective_id)
    assert obj.errors.invalid?(:perspective)
    assert !obj.errors.invalid?(:period_id)
    assert obj.errors.invalid?(:period)
    assert !obj.errors.invalid?(:creator)
    assert obj.errors.invalid?(:created_by)
    assert !obj.errors.invalid?(:updater)
    assert obj.errors.invalid?(:updated_by)
  end

  def test_valid_objective
    obj = new_objective
    persp = perspectives(:foo)
    obj.perspective = persp
    user = users(:foo)
    obj.created_by = user
    obj.updated_by = user
    period = periods(:foo)
    obj.period = period
    obj.save
    assert obj.valid?
    assert obj.save
  end
  
  def test_status_ok
    obj = Objective.new
    obj.value = 4
    obj.lower_limit = 1
    obj.upper_limit = 3
    assert_equal obj.status, 'ok'
  end

  def test_status_ko
    obj = Objective.new
    obj.value = 0
    obj.lower_limit = 1
    obj.upper_limit = 3
    assert_equal obj.status, 'ko'
  end

  def test_status_oo
    obj = Objective.new
    obj.value = 2
    obj.lower_limit = 1
    obj.upper_limit = 3
    assert_equal obj.status, 'oo'
  end

  private
  
  def new_objective
    Objective.new :name => 'Baz', :description => 'baz baz', :lower_limit => 1, :target => 2, :upper_limit => 3, :value => 4
  end
end
