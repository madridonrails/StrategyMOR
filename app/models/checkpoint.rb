require 'ajax_scaffold'

class Checkpoint < ActiveRecord::Base

  belongs_to :objective
  belongs_to :updated_by, :class_name => 'User', :foreign_key => 'updater'

  @scaffold_columns = [ 
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "enterprise_id", :label => 'Empresa', :eval => 'checkpoint.objective.perspective.area.enterprise.name', :sort_sql => 'ID'}), #HAY QUE DEFINIR ESTA ORDENACIÓN
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "area_id", :label => 'Cuadro de mando', :eval => 'checkpoint.objective.perspective.area.name', :sort_sql => 'ID'}), #HAY QUE DEFINIR ESTA ORDENACIÓN
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "objective_id", :label => 'Objetivo', :eval => 'checkpoint.objective.name', :sort_sql => 'objective_id'}), #HAY QUE DEFINIR ESTA ORDENACIÓN
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "update_date", :label => 'Fecha', :sort_sql => 'update_date'}),
#	AjaxScaffold::ScaffoldColumn.new(self, { :name => "lower_limit", :label => 'Inf.', :eval => 'checkpoint.objective.lower_limit', :sortable => false}),
#    AjaxScaffold::ScaffoldColumn.new(self, { :name => "target", :label => 'Meta', :eval => 'checkpoint.objective["target"]', :sortable => false}),
#    AjaxScaffold::ScaffoldColumn.new(self, { :name => "upper_limit", :label => 'Sup.', :eval => 'checkpoint.objective.upper_limit', :sortable => false}),
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "value", :label => 'Valor', :sortable => false}),
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "updated_by", :label => 'Actualizado por', :eval => 'checkpoint.updated_by.full_name', :sort_sql => 'checkpoints.updater'}),
  ]

  validates_presence_of     :objective_id,
                            :message => 'El punto de control debe estar asociado a un objetivo v&aacute;lido'
  validates_presence_of     :objective,
                            :message => 'El punto de control debe estar asociado a un objetivo v&aacute;lido'
  validates_presence_of     :updated_by,
                            :message => 'El punto de control debe estar asociado a un usuario v&aacute;lido'
  validates_presence_of     :updater,
                            :message => 'El punto de control debe estar asociado a un usuario v&aacute;lido'
  validates_presence_of     :update_date,
                            :message => 'La fecha es obligatoria'
  validates_presence_of     :target,
                            :message => 'La meta es obligatoria'
  validates_presence_of     :value,
                            :message => 'El valor es obligatorio'
  validates_presence_of     :upper_limit,
                            :message => 'El l&iacute;mite superior es obligatorio'
  validates_presence_of     :lower_limit,
                            :message => 'El l&iacute;mite inferior es obligatorio'
  validates_numericality_of :target,
                            :message => 'La meta ha de ser num&eacute;rica'
  validates_numericality_of :value,
                            :message => 'El valor ha de ser num&eacute;rico'
  validates_numericality_of :upper_limit,
                            :message => 'El l&iacute;mite superior ha de ser num&eacute;rico'
  validates_numericality_of :lower_limit,
                            :message => 'El l&iacute;mite inferior ha de ser num&eacute;rico'
  validates_length_of       :comments, :within => 0..255,
                            :too_long => 'El comentario es demasiado largo (m&aacute;ximo %d caracteres)'

  def formatted_update_date
    return self.update_date
  end
end
