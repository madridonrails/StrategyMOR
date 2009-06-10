require File.dirname(__FILE__) + '/../test_helper'

class AreaTest < Test::Unit::TestCase
  fixtures [:enterprises, :users]

  def test_invalid_with_blank_attributes
    area = Area.new
    assert !area.valid?
    assert area.errors.invalid?(:name)
    assert area.errors.invalid?(:enterprise_id)
    assert area.errors.invalid?(:enterprise)
    assert area.errors.invalid?(:owner)
    assert area.errors.invalid?(:owned_by)
  end

  def test_invalid_with_used_name_within_enterprise
    @enterprise = enterprises(:foo)
    @owner = users(:foo)
    area_baz = new_area('Baz')
    area_baz.enterprise = @enterprise
    area_baz.owner = @owner
    area_baz.save
    area_baz_2 = new_area('Baz')
    area_baz_2.enterprise = @enterprise
    area_baz_2.owner = @owner
    area_baz_2.save
    assert !area_baz_2.valid?
    assert !area_baz_2.errors.invalid?(:enterprise_id)
    assert !area_baz_2.errors.invalid?(:enterprise)
    assert !area_baz_2.errors.invalid?(:owned_by)
    assert !area_baz_2.errors.invalid?(:owner)
    assert area_baz_2.errors.invalid?(:name)
  end
  
  def test_invalid_with_inexistent_enterprise_and_owner
    area_baz = new_area('Baz')
    area_baz.enterprise_id = 50000
    area_baz.owner = 50000
    area_baz.save
    assert !area_baz.valid?
    assert !area_baz.errors.invalid?(:name)
    assert !area_baz.errors.invalid?(:enterprise_id)
    assert area_baz.errors.invalid?(:enterprise)
    assert !area_baz.errors.invalid?(:owner)
    assert area_baz.errors.invalid?(:owned_by)
  end

  def test_valid_area
    @enterprise = enterprises(:foo)
    @owner = users(:foo)
    area_baz = new_area('Baz')
    area_baz.enterprise = @enterprise
    area_baz.owner = @owner
    area_baz.save
    assert area_baz.valid?
    assert area_baz.save
    assert area_baz.perspectives.count == 4
  end

  private
  
  def new_area(name)
    Area.new :name => name
  end
end
