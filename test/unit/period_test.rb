require File.dirname(__FILE__) + '/../test_helper'

class PeriodTest < Test::Unit::TestCase
  fixtures [:time_units]

  def test_invalid_with_blank_attributes
    period = Period.new
    assert !period.valid?
    assert period.errors.invalid?(:days)
    assert period.errors.invalid?(:time_unit_id)
    assert period.errors.invalid?(:time_unit)
  end

  def test_invalid_with_inexistent_time_unit
    period = Period.new
    period.days = 1
    period.time_unit_id = 10000
    assert !period.valid?
    assert !period.errors.invalid?(:days)
    assert !period.errors.invalid?(:time_unit_id)
    assert period.errors.invalid?(:time_unit)
  end

  def test_valid_user
    period = Period.new
    period.days = 1
    period.time_unit = time_units(:foo)
    assert period.valid?
    assert period.save
  end
end
