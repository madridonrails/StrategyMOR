require 'ajax_scaffold'

class Perspective < ActiveRecord::Base
  belongs_to :area
  has_many   :objectives, :dependent => :destroy, :order => 'position ASC'

  acts_as_list :scope => :area

  @scaffold_columns = [ 
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "enterprise_id", :label => 'Empresa', :eval => 'perspective.area.enterprise.name',     :sort_sql => 'perspectives.id'}), #hacer bien la ordenacion
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "area_id", :label => 'Cuadro de mando', :eval => 'perspective.area.name', :sort_sql => 'perspectives.area_id'}),
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "name", :label => 'Nombre', :sort_sql => 'perspectives.name'}),
  ]

  validates_presence_of     :name,
                            :message => 'El nombre no puede estar vac&iacute;o.'
  validates_length_of       :name, :within => 0..255,
                            :too_long => 'El nombre es demasiado largo (m&aacute;ximo %d caracteres)'
  validates_uniqueness_of   :name, :scope => :area_id,
                            :message => 'El nombre debe ser &uacute;nico'
  validates_presence_of     :area_id,
                            :message => 'La perspectiva debe estar asociada a un cuadro de mando v&aacute;lido'
  validates_presence_of     :area,
                            :message => 'La perspectiva debe estar asociada a un cuadro de mando v&aacute;lido'

end
