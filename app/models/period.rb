require 'ajax_scaffold'

class Period < ActiveRecord::Base
  belongs_to :time_unit
  has_many   :objectives, :dependent => :nullify

  @scaffold_columns = [ 
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "days", :label => 'D&iacute;a del per&iacute;odo', :sort_sql => 'periods.days'}),
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "time_unit_id", :label => 'Unidad temporal', :sort_sql => 'periods.time_unit_id', :eval => 'period.time_unit.name'})
  ]

  validates_presence_of     :days,
                            :message => 'El d&iacute;a no puede estar vac&iacute;o'
  validates_numericality_of :days, :only_integer => true,
                            :message => 'El d&iacute;a ha de ser num&eacute;rico'
  validates_presence_of     :time_unit_id,
                            :message => 'La periodicidad debe estar asociada a una unidad de tiempo v&aacute;lida'
  validates_presence_of     :time_unit,
                            :message => 'La periodicidad debe estar asociada a una unidad de tiempo v&aacute;lida'

  def full_name
    if (self.time_unit.name == 'dia')
	  return 'cada dia' 
	elsif (self.time_unit.name == 'semana')
      return 'el ' + BscgemUtils::day_of_week(days) + ' de cada semana' 
	else
      return 'el dia ' + days.to_s + ' de cada ' + self.time_unit.name
	end
  end
end
