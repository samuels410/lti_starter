class UserConfig < ActiveRecord::Base
   attr_accessible :access_token, :name,:image,:global_user_id,:user_id,:domain_id
  belongs_to :domain

   def host
     self.domain && self.domain.host
   end

end
