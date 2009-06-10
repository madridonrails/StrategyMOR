require 'digest/sha1'

class User < ActiveRecord::Base
  # Virtual attribute for the unencrypted password
  attr_accessor :password

  has_many :dependent_areas, :class_name => 'Area', :foreign_key => 'owner', :dependent => :nullify
  has_many :created_objectives, :class_name => 'Objective', :foreign_key => 'creator', :dependent => :nullify
  has_many :dependent_objectives, :class_name => 'Objective', :foreign_key => 'updater', :dependent => :nullify
  has_many :dependent_initiatives, :class_name => 'Initiative', :foreign_key => 'assigned_to', :dependent => :nullify

  belongs_to :enterprise
  belongs_to :profile

#  add_for_sorting_to :first_name, :last_name

  before_save :encrypt_password

  @scaffold_columns = [ 
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "first_name", :label => 'Nombre', :sort_sql => 'users.first_name'}),
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "last_name", :label => 'Apellidos', :sort_sql => 'users.last_name'}),
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "email", :label => 'e-mail', :sort_sql => 'users.email'}),
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "profile_id", :label => 'Perfil', :eval => 'user.profile.name', :sort_sql => 'users.profile_id'}),
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "enterprise_id", :label => 'Empresa', :eval => 'user.enterprise.name', :sort_sql => 'users.enterprise_id'})
  ]

  validates_presence_of     :email,
                            :message => 'El email no puede estar vac&iacute;o'
  validates_presence_of     :password, :if => :password_required?,
                            :message => 'La password no puede estar vac&iacute;a'
  validates_presence_of     :password_confirmation, :if => :password_required?,
                            :message => 'La confirmaci&oacute;n no puede estar vac&iacute;a'
  validates_length_of       :password, :within => 4..40, :if => :password_required?,
                            :too_long => 'la password es demasiado larga (m&aacute;ximo %d caracteres)',
                            :too_short => 'La password es demasiado corta (m&iacute;nimo %d caracteres)'
  validates_confirmation_of :password, :if => :password_required?,
                            :message => 'La confirmaci&oacute;n ha de ser similar a la password'
  validates_length_of       :email,    :within => 3..100,
                            :too_long => 'El email es demasiado largo (m&aacute;ximo %d caracteres)',
                            :too_short => 'El email es demasiado corto (m&iacute;nimo %d caracteres)'
  validates_uniqueness_of   :email, :case_sensitive => false,
                            :message => 'Existe un usuario con este email.'
  validates_presence_of     :first_name,
                            :message => 'El nombre no puede estar vac&iacute;o'
  validates_length_of       :first_name, :within => 0..255,
                            :too_long => 'El nombre es demasiado largo (m&aacute;ximo %d caracteres)'
  validates_presence_of     :last_name,
                            :message => 'Los apellidos no pueden estar vac&iacute;os'
  validates_length_of       :last_name, :within => 0..255,
                            :too_long => 'Los apellidos son demasiado largos (m&aacute;ximo %d caracteres)'
  validates_presence_of     :enterprise_id,
                            :message => 'El usuario debe estar asociado a una empresa v&aacute;lida'
  validates_presence_of      :enterprise,
                            :message => 'El usuario debe estar asociado a una empresa v&aacute;lida'
  validates_presence_of     :profile_id,
                            :message => 'El usuario debe tener un perfil v&aacute;lido'
  validates_presence_of      :profile,
                            :message => 'El usuario debe tener un perfil v&aacute;lido'

  # Authenticates a user by their email name and unencrypted password.  Returns the user or nil.
  def self.authenticate(email, password, subdomain)
    u = find_by_email(email) 
	if u && u.authenticated?(password) && u.enterprise.alias == subdomain 
	  u
    else
      nil
	end
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  #firstname + last_name
  def full_name
    return first_name + ' ' + last_name
  end
  
  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    self.remember_token_expires_at = 2.weeks.from_now.utc
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  def set_new_password()
    new_password = generate_password()
    self.password = self.password_confirmation = new_password
    self.save!
    return new_password
  end
  
  def self.find_by_enterprise_and_privilege(enterprise_id, privilege, privilege_values)
    if privilege_values.class.to_s == 'String'
	  privilege_values = privilege_values.split('#')
    else
      logger.info privilege_values.class
	end
    return User.find(:all, :conditions => ["enterprise_id = ? and privilege#{privilege} in ('#{privilege_values.join('\',\'')}')", enterprise_id], :include => [:profile])
  end
  
  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{email}--") if new_record?
      self.crypted_password = encrypt(password)
    end
    
    def password_required?
      crypted_password.blank? || !password.blank?
    end

    #Genera una password aleatorio
    def generate_password(length = 8)
      chars = ('a'..'z').to_a + ('A'..'Z').to_a + ('1'..'9').to_a - ['o', 'O', 'i', 'I']
      Array.new(length) { chars[rand(chars.size)] }.join
    end

end
