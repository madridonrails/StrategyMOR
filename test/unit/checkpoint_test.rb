require File.dirname(__FILE__) + '/../test_helper'

class CheckpointTest < Test::Unit::TestCase
  fixtures [:enterprises, :users, :areas, :perspectives, :periods, :objectives]

  def test_invalid_with_blank_attributes
    chkp = Checkpoint.new
    assert !chkp.valid?
    assert chkp.errors.invalid?(:objective_id)
    assert chkp.errors.invalid?(:objective)
    assert chkp.errors.invalid?(:updater)
    assert chkp.errors.invalid?(:updated_by)
    assert chkp.errors.invalid?(:update_date)
    assert chkp.errors.invalid?(:target)
    assert chkp.errors.invalid?(:value)
    assert chkp.errors.invalid?(:upper_limit)
    assert chkp.errors.invalid?(:lower_limit)
  end

  def test_invalid_with_inexistent_objective_and_updater
    chkp = new_checkpoint
    chkp.objective_id = 50000
    chkp.updater = 50000
    chkp.save
    assert !chkp.valid?
    assert !chkp.errors.invalid?(:update_date)
    assert !chkp.errors.invalid?(:target)
    assert !chkp.errors.invalid?(:value)
    assert !chkp.errors.invalid?(:upper_limit)
    assert !chkp.errors.invalid?(:lower_limit)
    assert !chkp.errors.invalid?(:objective_id)
    assert chkp.errors.invalid?(:objective)
    assert !chkp.errors.invalid?(:updater)
    assert chkp.errors.invalid?(:updated_by)
  end

  def test_valid_checkpoint
    chkp = new_checkpoint
    obj = objectives(:foo)
    chkp.objective = obj
    user = users(:foo)
    chkp.updater = user
    chkp.save
    assert chkp.valid?
    assert chkp.save
  end
  private
  
  def new_checkpoint
    Checkpoint.new :comments => 'baz baz', :update_date => Date.today, :lower_limit => 1, :target => 2, :upper_limit => 3, :value => 4
  end
end
