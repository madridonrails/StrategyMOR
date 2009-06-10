require File.dirname(__FILE__) + '/../test_helper'

class InitiativeTest < Test::Unit::TestCase
  fixtures [:enterprises, :users, :areas, :perspectives, :periods, :objectives]

  def test_invalid_with_blank_attributes
    init = Initiative.new
    assert !init.valid?
    assert init.errors.invalid?(:name)
    assert init.errors.invalid?(:description)
    assert init.errors.invalid?(:objective_id)
    assert init.errors.invalid?(:objective)
    assert init.errors.invalid?(:assigned_to)
    assert init.errors.invalid?(:assigned)
    assert init.errors.invalid?(:budget)
    assert init.errors.invalid?(:ini_date)
    assert init.errors.invalid?(:end_date)
  end

  def test_invalid_with_inexistent_objective_and_assigned
    init = new_initiative
    init.objective_id = 50000
    init.assigned_to = 50000
    init.save
    assert !init.valid?
    assert !init.errors.invalid?(:name)
    assert !init.errors.invalid?(:description)
    assert !init.errors.invalid?(:budget)
    assert !init.errors.invalid?(:ini_date)
    assert !init.errors.invalid?(:end_date)
    assert !init.errors.invalid?(:objective_id)
    assert init.errors.invalid?(:objective)
    assert !init.errors.invalid?(:assigned_to)
    assert init.errors.invalid?(:assigned)
  end

  def test_valid_initiative
    init = new_initiative
    obj = objectives(:foo)
    init.objective = obj
    user = users(:foo)
    init.assigned_to = user
    init.save
    assert init.valid?
    assert init.save
  end
  private
  
  def new_initiative
    Initiative.new :name => 'Baz', :description => 'baz baz', :ini_date => Date.today, :end_date => Date.today + 2, :budget => 3000, :budget_attribute => 'euros'
  end
end
