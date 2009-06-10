require File.dirname(__FILE__) + '/../test_helper'

class TimeUnitTest < Test::Unit::TestCase
  def test_invalid_with_blank_attributes
    tunit = TimeUnit.new
    assert !tunit.valid?
    assert tunit.errors.invalid?(:name)
    assert tunit.errors.invalid?(:adjective)
    assert tunit.errors.invalid?(:days)
  end

  def test_valid_time_unit
    tunit = TimeUnit.new :name => 'bar', :adjective => 'barly', :days => 100
    assert tunit.valid?
    assert tunit.save
  end
end
