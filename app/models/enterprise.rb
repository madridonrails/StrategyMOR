require 'ajax_scaffold'

class Enterprise < ActiveRecord::Base
  acts_as_attachment :storage => :file_system, :file_system_path => "#{UPLOADED_FILES_PATH}/enterprises"

  has_many :users, :dependent => :destroy
  has_many :areas, :dependent => :destroy

  after_attachment_saved do |record|
    temp_path =  File.join(RAILS_ROOT, record.attachment_options[:file_system_path], record.attachment_path_id)
    temp_time = File.mtime(temp_path)
	Dir.foreach(temp_path) do |f|
	  if f != '.' && f != '..'
	    if File.mtime(File.join(temp_path, f)) < temp_time
		  File.delete(File.join(temp_path, f))
		end
	  end
	end
  end
  after_destroy :destroy_dir

  @scaffold_columns = [ 
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "name", :label => 'Nombre', :sort_sql => 'enterprises.name'}),
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "alias", :label => 'Alias', :sort_sql => 'enterprises.alias'}),
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "contact", :label => 'Informaci&oacute;n de contacto', :sortable => false}),
  ]

  validates_presence_of     :name,
                            :message => 'El nombre es obligatorio'
  validates_uniqueness_of   :name,
                            :message => 'Ya existe una empresa con este nombre.'                            
  validates_presence_of     :alias,
                            :message => 'El alias es obligatorio'
  validates_uniqueness_of   :alias,
                            :message => 'Ya existe una empresa con este alias.'                            

  def destroy_attachment
    self[:filename] = nil
    self[:content_type] = nil
    self[:size] = nil
	self.save
    destroy_dir
  end

private
  def destroy_dir
    FileUtils.rmtree File.join(RAILS_ROOT, attachment_options[:file_system_path], attachment_path_id) rescue nil
  end
end
