class FeatureSet < ActiveRecord::Base
 attr_accessible :organization_id,:name ,:no_students,:no_teachers,:no_admins,:no_courses,:storage,:unlimited

 validates :name,:organization_id, presence: true

 belongs_to :organization
  has_many :subscription_plans

end
