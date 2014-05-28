class UserConfig < ActiveRecord::Base
   attr_accessible :access_token, :name,:image,:global_user_id
  belongs_to :domain
end
