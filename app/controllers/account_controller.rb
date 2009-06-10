class AccountController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  # If you want "remember me" functionality, add this before_filter to Application Controller
  before_filter :login_from_cookie

  def index
    render :action => 'index', :controller => 'account'
  end

  def login
    return unless request.post?
    self.current_user = User.authenticate(params[:email], params[:password], account_subdomain)
    if current_user
      if params[:remember_me] == '1'
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      redirect_to( :host => account_host(), :controller => '/account', :action => 'index')
    else
      flash[:error] = 'Email o password incorrecto en el dominio'
      redirect_to(:controller => '/web', :action => 'login')
    end
  end

  def register
    begin
      Enterprise.transaction do
        @enterprise = Enterprise.new
        @enterprise.name = params[:enterprise_name]
        @enterprise.alias = params[:enterprise_alias]
        @enterprise.css = 'default'
        @enterprise.save!
        @user = User.new()
        @user.password = params[:password]
        @user.password_confirmation = params[:password_confirmation]
        @user.first_name = params[:first_name]
        @user.last_name = params[:last_name]
        @user.email = params[:email]
        @user.profile_id = BscgemUtils::profile('enterprise manager')
        @user.enterprise_id = @enterprise.id
        @user.save!
      end
      self.current_user = @user
      flash[:notice] = "Registro realizado correctamente.<br/>Ya puedes acceder a la aplicaci&oacute;n."
      if request.xhr?
        render :update do |page|
          page.redirect_to('/account/index')
          flash[:error], flash[:notice] = nil
        end
      else
        redirect_to('/account/index')
      end
      return
    rescue
      flash[:error] = "Registro no realizado<br/>"
      @enterprise.errors.each{|attr,msg| flash[:error] <<  "#{msg}<br/>"} if @enterprise
      @user.errors.each{|attr,msg| flash[:error] <<  "#{msg}<br/>"} if @user
    end

    if request.xhr?
      render :update do |page|
        page.show('message_area')
        page.replace_html 'message_area', flash[:error].nil? ? flash[:notice] : flash[:error]
        flash[:error], flash[:notice] = nil
      end
    else
      redirect_to('/web/register')
    end
  end
  
  def logout
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    redirect_back_or_default(:controller => '/web')
  end

  def new_password    
    email = params[:email]    
    subdomain = params[:subdomain]    
    if subdomain.blank?
      flash[:error] = 'Por favor facilita un subdominio'
    elsif email.blank?
      flash[:error] = 'Por favor facilita un email'
    else
      user = User.find_by_email(email)
      enterprise = Enterprise.find_by_alias(subdomain)
      if !user
        flash[:error] =  "No existe ning&uacute;n usuario con email #{email}"
      elsif !enterprise
        flash[:error] =  "No existe ninguna empresa asociada al subdominio #{subdomain}"
      elsif user.enterprise_id != enterprise[:id]
        flash[:error] =  "No existe ning&uacute;n usuario con email #{email} en el subdominio #{subdomain}"
      else
        begin
          new_password = user.set_new_password
        rescue Exception => e
          flash[:error] =  'No se pudo generar una password nueva'
        else
          begin
            Notifier.deliver_new_password(user, new_password)
          rescue Exception => e
            flash[:error] =  "No se pudo enviar el correo con la nueva password"
          else
            flash[:notice] = "Se ha enviado un nuevo password a #{email}"        
          end
        end 
      end
    end
    if request.xhr?
      render :update do |page|
        page.show('message_area')
        page.replace_html 'message_area', flash[:error].nil? ? flash[:notice] : flash[:error]
        flash[:error], flash[:notice] = nil
      end
    else
      redirect_to('/web/forgot')
    end
  end
end
