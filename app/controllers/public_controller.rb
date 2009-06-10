class PublicController < ApplicationController  
  
  #To check Exception Notifier
  def error  
    raise RuntimeError, "Generating an error"  
  end   
  
 end
