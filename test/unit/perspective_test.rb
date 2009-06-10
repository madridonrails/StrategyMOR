require File.dirname(__FILE__) + '/../test_helper'

class PerspectiveTest < Test::Unit::TestCase
  fixtures [:enterprises, :users, :areas]

  def test_invalid_with_blank_attributes
    persp = Perspective.new
    assert !persp.valid?
    assert persp.errors.invalid?(:name)
    assert persp.errors.invalid?(:area_id)
    assert persp.errors.invalid?(:area)
  end

  def test_invalid_with_used_name_within_area
    @area = areas(:foo)
    persp_baz = new_perspective('Baz')
    persp_baz.area = @area
    persp_baz.save
    persp_baz_2 = new_perspective('Baz')
    persp_baz_2.area = @area
    persp_baz_2.save
    assert !persp_baz_2.valid?
    assert !persp_baz_2.errors.invalid?(:area_id)
    assert !persp_baz_2.errors.invalid?(:area)
    assert persp_baz_2.errors.invalid?(:name)
  end
  
  def test_invalid_with_inexistent_area
    persp_baz = new_perspective('Baz')
    persp_baz.area_id = 50000
    persp_baz.save
    assert !persp_baz.valid?
    assert !persp_baz.errors.invalid?(:name)
    assert !persp_baz.errors.invalid?(:area_id)
    assert persp_baz.errors.invalid?(:area)
  end

  def test_valid_perspective
    @area = areas(:foo)
    persp_baz = new_perspective('Baz')
    persp_baz.area = @area
    persp_baz.save
    assert persp_baz.valid?
    assert persp_baz.save
  end

  private
  
  def new_perspective(name)
    Perspective.new :name => name
  end
end
