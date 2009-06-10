require 'ajax_scaffold'

class Profile < ActiveRecord::Base

  has_many :users, :dependent => :nullify

  @scaffold_columns = [ 
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "name", :label => 'Nombre', :sort_sql => 'profiles.name'}),
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "privilege1", :label => 'Empresas', :sort_sql => 'profiles.privilege1'}),
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "privilege2", :label => 'Perfiles', :sort_sql => 'profiles.privilege2'}),
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "privilege3", :label => 'Periodos', :sort_sql => 'profiles.privilege3'}),
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "privilege4", :label => 'Usuarios', :sort_sql => 'profiles.privilege4'}),
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "privilege5", :label => 'Cuadros', :sort_sql => 'profiles.privilege5'}),
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "privilege6", :label => 'Objetivos', :sort_sql => 'profiles.privilege6'}),
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "privilege7", :label => 'Iniciativas', :sort_sql => 'profiles.privilege7'}),
  ]

  validates_presence_of     :name,
                            :message => 'El nombre es obligatorio'
  validates_uniqueness_of   :name,
                            :message => 'Ya existe un perfil con ese nombre.'                            
  validates_presence_of     :privilege1,
                            :message => 'El permiso para empresas es obligatorio'
  validates_presence_of     :privilege2,
                            :message => 'El permiso para perfiles es obligatorio'
  validates_presence_of     :privilege3,
                            :message => 'El permiso para periodos es obligatorio'
  validates_presence_of     :privilege4,
                            :message => 'El permiso para usuarios es obligatorio'
  validates_presence_of     :privilege5,
                            :message => 'El permiso para cuadros de mando es obligatorio'
  validates_presence_of     :privilege6,
                            :message => 'El permiso para objetivos es obligatorio'
  validates_presence_of     :privilege7,
                            :message => 'El permiso para iniciativas es obligatorio'

  def self.create_default
    profile = Profile.new
    profile.id      = 1
    profile.name      = 'master'
    profile.privilege1 = 'X'
    profile.privilege2 = 'X'
    profile.privilege3 = 'X'
    profile.privilege4 = 'X'
    profile.privilege5 = 'X'
    profile.privilege6 = 'X'
    profile.privilege7 = 'X'
    profile.privilege8 = 'X'
    user.save!
  end

end
