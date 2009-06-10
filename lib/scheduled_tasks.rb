module ScheduledTasks
  def self.generate_objective_warnings(d = Date.today)
    week_day = d.cwday()
    month_day = [d.mday()]
    m = d.month()
    if month_day[0] == 30 && (m == 4 || m == 6 || m == 9 || m == 11)
	  month_day << 31
	elsif m == 2
	  if month_day[0] == 28 && !Date.gregorian_leap(d.year())
        month_day << 31 << 30
	  elsif month_day[0] == 29
        month_day << 31 << 30 << 29
	  end
	end
	
    objs = Objective.find(:all, 
	  :conditions => [' time_units.days = 1 OR (time_units.days = 7 AND periods.days = ?) OR (time_units.days = 31 AND periods.days IN (?))', 
	    week_day, month_day.join(",")], 
	  :include => [{:period => [:time_unit]}])
	
	objs.each {|o| Notifier::deliver_objective_update_warning(o)}
  end
end

