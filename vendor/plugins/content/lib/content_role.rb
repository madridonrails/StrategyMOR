class ContentRole < ActiveRecord::Base
  has_many :content_pages, :dependent=>:nullify
end
