require 'ajax_scaffold'

class Area < ActiveRecord::Base
  belongs_to :enterprise
  belongs_to :owned_by, :class_name => 'User', :foreign_key => 'owner'
  has_many   :perspectives, :dependent => :destroy, :order => 'position ASC'
 
  after_create :insert_default_perspectives
 
  @scaffold_columns = [ 
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "enterprise_id", :label => 'Empresa', :eval => 'area.enterprise.name', :sort_sql => 'enterprise_id'}),
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "name", :label => 'Nombre', :sort_sql => 'areas.name'}), 
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "owner", :label => 'Responsable', :eval => 'area.owned_by.full_name', :sort_sql => 'areas.owner'})
  ]

  validates_presence_of     :name,
                            :message => 'El nombre no puede estar vac&iacute;o'
  validates_uniqueness_of   :name, :scope => :enterprise_id,
                            :message => 'El nombre debe ser &uacute;nico'
  validates_length_of       :name, :within => 0..255,
                            :too_long => 'El nombre es demasiado largo (m&aacute;ximo %d caracteres)'
  validates_presence_of     :enterprise_id,
                            :message => 'El cuadro de mando debe estar asociado a una empresa v&aacute;lida'
  validates_presence_of     :enterprise,
                            :message => 'El cuadro de mando debe estar asociado a una empresa v&aacute;lida'
  validates_presence_of     :owner,
                            :message => 'El cuadro de mando debe estar asociado a un responsable v&aacute;lido'
  validates_presence_of     :owned_by,
                            :message => 'El cuadro de mando debe estar asociado a un responsable v&aacute;lido'

  def max_order_number
    n = self.perspectives.length
  	if(n==0)
  	  return 0
  	else
  	  return self.perspectives[n-1].order_number
  	end
  end

private
  def insert_default_perspectives
    clientes = Perspective.new
    clientes.name = "Clientes"
    clientes.area_id = self.id
    clientes.save
    formacion = Perspective.new
    formacion.name = "Formacion"
    formacion.area_id = self.id
    formacion.save
    procesos = Perspective.new
    procesos.name = "Procesos"
    procesos.area_id = self.id
    procesos.save
    finanzas = Perspective.new
    finanzas.name = "Finanzas"
    finanzas.area_id = self.id
    finanzas.save
  end
end
