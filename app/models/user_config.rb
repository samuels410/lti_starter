class UserConfig < ActiveRecord::Base

   belongs_to :domain

   def host
     self.domain && self.domain.host
   end

end
