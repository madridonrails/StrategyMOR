require 'ajax_scaffold'

class Initiative < ActiveRecord::Base
  belongs_to :objective
  belongs_to :assigned, :class_name => 'User', :foreign_key => 'assigned_to'

  @scaffold_columns = [ 
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "enterprise_id", :label => 'Empresa', :eval => 'initiative.objective.perspective.area.enterprise.name', :sort_sql => 'enterprises.name'}),
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "area_id", :label => 'Cuadro', :eval => 'initiative.objective.perspective.area.name',  :sort_sql => 'areas.name'}),
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "objective_id", :label => 'Objetivo', :eval => 'initiative.objective.name', :sort_sql => 'objectives.name'}),
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "name", :label => 'Nombre', :sort_sql => 'initiatives.name'}),
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "ini_date", :label => 'Inicio', :sort_sql => 'initiatives.ini_date'}),
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "end_date", :label => 'Fin', :sort_sql => 'initiatives.end_date'}),
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "assigned", :label => 'Responsable', :eval => 'initiative.assigned.full_name', :sort_sql => 'initiatives.assigned_to'}),
  AjaxScaffold::ScaffoldColumn.new(self, { :name => "budget", :label => 'Presupuesto', :sort_sql => 'initiatives.budget'}),
  ]

  validates_length_of       :name, :within => 0..255,
                            :too_long => 'El nombre es demasiado largo (m&aacute;ximo %d caracteres)'
  validates_presence_of     :name,
                            :message => 'El nombre no puede estar vac&iacute;o'
  validates_length_of       :description, :within => 0..255,
                            :too_long => 'La descripci&oacute;n es demasiado larga (m&aacute;ximo %d caracteres)'
  validates_presence_of     :description,
                            :message => 'La descripci&oacute;n no puede estar vac&iacute;a'
  validates_presence_of     :objective_id,
                            :message => 'La iniciativa debe estar asociado a un objetivo v&aacute;lido'
  validates_presence_of     :objective,
                            :message => 'La iniciativa debe estar asociado a un objetivo v&aacute;lido'
  validates_presence_of     :ini_date,
                            :message => 'La fecha de inicio no puede estar vac&iacute;a'
  validates_presence_of     :end_date,
                            :message => 'La fecha de fin no puede estar vac&iacute;a'
  validates_presence_of     :budget,
                            :message => 'El presupuesto no puede estar vac&iacute;o'
  validates_numericality_of :budget,
                            :message => 'El presupuesto ha de ser num&eacute;rico'
  validates_presence_of     :assigned_to,
                            :message => 'El objetivo debe estar asociado a un responsable v&aacute;lido'
  validates_presence_of     :assigned,
                            :message => 'El objetivo debe estar asociado a un responsable v&aacute;lido'
  
end
