module BscgemUtils
  PAGE_SIZE = 10
  
  PERMISSION = {'-'=>'N','todos'=>'X','los de tu empresa'=>'E','los de tus dashboards'=>'A','los de tus objetivos'=>'O', 'usuario propio'=>'U'}
  PROFILE = {'master'=>1,'minimaster'=>2,'enterprise manager'=>3,'dashboard manager'=>4,'objective manager'=>5 }
  DAYS_OF_WEEK = {1=>'lunes', 2=>'martes', 3=>'miercoles', 4=>'jueves', 5=>'viernes', 6=>'sabado', 7=>'domingo'}
  
  def self.profile(p)
	PROFILE[p]
  end

  def self.day_of_week(d)
	DAYS_OF_WEEK[d]
  end

end

