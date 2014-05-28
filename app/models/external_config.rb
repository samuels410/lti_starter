class ExternalConfig < ActiveRecord::Base
   attr_accessible :config_type, :app_name
   belongs_to :organization

end
