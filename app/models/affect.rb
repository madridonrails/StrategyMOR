require 'ajax_scaffold'

class Affect < ActiveRecord::Base

  belongs_to :affected, :class_name => 'Objective', :foreign_key => 'is_affected' 
  belongs_to :affecting, :class_name => 'Objective', :foreign_key => 'affects' 

  @scaffold_columns = [ 
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "enterprise_id", :label => 'Empresa', :eval => 'affect.affected.perspective.area.enterprise.name',:sort_sql => 'ID'}), #HAY QUE DEFINIR ESTA ORDENACIÓN
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "area_id", :label => 'Cuadro de mando', :eval => 'affect.affected.perspective.area.name',  :sort_sql => 'ID'}), #HAY QUE DEFINIR ESTA ORDENACIÓN
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "affected", :label => 'Objetivo', :eval => 'affect.affected.name', :sort_sql => 'affects.is_affected'}),
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "affecting", :label => 'Depende de', :eval => 'affect.affecting.name', :sort_sql => 'affects.affects'})
  ]
  
  validates_presence_of     :affects,
                            :message => 'La relacci&oacute;n debe depender de un objetivo v&aacute;lido'
  validates_presence_of     :affecting,
                            :message => 'La relacci&oacute;n debe depender de un objetivo v&aacute;lido'
  validates_presence_of     :is_affected,
                            :message => 'El objetivo no es v&aacute;lido'
  validates_presence_of     :affected,
                            :message => 'El objetivo no es v&aacute;lido'
  validates_uniqueness_of   :is_affected, :scope => :affects,
                            :message => 'La relaci&oacute;n ya existe'
end
