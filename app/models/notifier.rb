class Notifier < ActionMailer::Base
  def objective_update_warning(objective)
    @recipients = objective.updated_by.email
    @from = "danimata@aspgems.com"
    @subject = "Actualizacion del objetivo " + objective.name
    @sent_on    = Time.now
    @headers    = {}

    @body["first_name"] = objective.updated_by.first_name
    @body["last_name"] = objective.updated_by.last_name
	@body["objective_id"] = objective.id
	@body["objective_name"] = objective.name
    @body["objective_period_time_unit_adjective"] = objective.period.time_unit.adjective
    @body["domain"]="#{user.enterprise.alias}.#{DOMAIN_NAME}" 
    #@body["objective_perspective_area_owner"] = objective.period.time_unit.adjective
  end

  def new_password(user, new_password)
    @subject    = "Nuevo password para #{DOMAIN_NAME}"
    @recipients = user.email
    @from       = "danimata@aspgems.com"
    @sent_on    = Time.now
    @headers    = {}
    
    @body["first_name"] = user.first_name
    @body["last_name"] = user.last_name
    @body["new_password"] = new_password
    @body["enterprise_name"] = user.enterprise.name
    @body["domain"]="#{user.enterprise.alias}.#{DOMAIN_NAME}" 
  end

end
