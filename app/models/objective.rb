require 'ajax_scaffold'

class Objective < ActiveRecord::Base
  belongs_to :period
  belongs_to :perspective
  belongs_to :created_by, :class_name => 'User', :foreign_key => 'creator'
  belongs_to :updated_by, :class_name => 'User', :foreign_key => 'updater'
  has_many   :affected_objectives, :class_name => 'Affect', :foreign_key => 'affects', :dependent => :destroy
  has_many   :affecting_objectives, :class_name => 'Affect', :foreign_key => 'is_affected', :dependent => :destroy
  has_many   :initiatives, :dependent => :destroy
  has_many   :checkpoints, :dependent => :destroy

  after_create :generate_checkpoint
  acts_as_list :scope => :perspective

  @scaffold_columns = [ 
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "enterprise_id", :label => 'Empresa', :eval => 'objective.perspective.area.enterprise.name', :sort_sql => 'enterprises.name'}),
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "area_id", :label => 'Cuadro', :eval => 'objective.perspective.area.name', :sort_sql => 'areas.name'}),
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "name", :label => 'Nombre', :sort_sql => 'objectives.name'}),
	AjaxScaffold::ScaffoldColumn.new(self, { :name => "lower_limit", :label => 'Inf.', :sortable => false}),
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "target", :label => 'Meta', :sortable => false}),
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "upper_limit", :label => 'Sup.', :sortable => false}),
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "value", :label => 'Valor', :sortable => false}),
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "updated_by", :label => 'Responsable', :eval => 'objective.updated_by.full_name', :sort_sql => 'objectives.updater'}),
  ]

  validates_length_of       :name, :within => 0..255,
                            :too_long => 'El nombre es demasiado largo (m&aacute;ximo %d caracteres)'
  validates_presence_of     :name,
                            :message => 'El nombre no puede estar vac&iacute;o'
  validates_length_of       :description, :within => 0..255,
                            :too_long => 'La descripci&oacute;n es demasiado larga (m&aacute;ximo %d caracteres)'
  validates_presence_of     :description,
                            :message => 'La descripci&oacute;n no puede estar vac&iacute;a'
  validates_presence_of     :perspective_id,
                            :message => 'El objetivo debe estar asociado a una perspectiva v&aacute;lida'
  validates_presence_of     :perspective,
                            :message => 'El objetivo debe estar asociado a una perspectiva v&aacute;lida'
  validates_presence_of     :period_id,
                            :message => 'El objetivo debe estar asociado a una periodicidad v&aacute;lida'
  validates_presence_of     :period,
                            :message => 'El objetivo debe estar asociado a una periodicidad v&aacute;lida'
  validates_presence_of     :creator,
                            :message => 'El objetivo debe estar asociado a un creador v&aacute;lido'
  validates_presence_of     :created_by,
                            :message => 'El objetivo debe estar asociado a un creador v&aacute;lido'
  validates_presence_of     :updater,
                            :message => 'El objetivo debe estar asociado a un responsable v&aacute;lido'
  validates_presence_of     :updated_by,
                            :message => 'El objetivo debe estar asociado a un responsable v&aacute;lido'
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
							
  def status
    if self.value < self.lower_limit
      return 'ko'
    elsif self.value > self.upper_limit
      return 'ok'
    else
      return 'oo'
    end
  end

private
  def generate_checkpoint
    c = Checkpoint.new
	c.upper_limit = self.upper_limit
	c.lower_limit = self.lower_limit
	c.target = self.target
	c.value = self.value
	c.comments = 'automatically generated'
	c.update_date = Date.today
	c.objective_id = self.id
	c.updater = self.creator
	c.save
  end

  validates_presence_of     :name,
                           :message => 'El nombre no puede estar vac&iacute;o.'

end
