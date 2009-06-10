class ContentPublishAction < ActiveRecord::Base
  def self.last_export
    last_import=ContentPublishAction.find(:first,:conditions=>"action_type='E'", :order=>'CREATED_AT DESC')
  end
  
  def self.last_import
    last_import=ContentPublishAction.find(:first,:conditions=>"action_type='I'", :order=>'CREATED_AT DESC')
  end
  
  def self.last_publication
    last_import=ContentPublishAction.find(:first,:conditions=>"action_type='P'", :order=>'CREATED_AT DESC')
  end
  
  def self.export_mark
    ContentPublishAction.new(:action_type=>'E').save
  end
  
  def self.import_mark
    ContentPublishAction.new(:action_type=>'I').save
  end
  
  def self.publication_mark
    ContentPublishAction.new(:action_type=>'P').save
  end
end
