class TimeUnit < ActiveRecord::Base
 has_many :periods, :dependent => :nullify

 validates_presence_of     :name,
                           :message => '^El nombre no puede estar vac�o.'
 validates_presence_of     :adjective,
                           :message => '^El adjetivo no puede estar vac�o.'
 validates_presence_of     :days,
                           :message => '^Los d&iacute;as no pueden estar vac�os.'

end
