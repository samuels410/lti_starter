class FeatureSet < ActiveRecord::Base
 attr_accessible :organization_id,:name ,:price,:no_students,:no_teachers,:no_admins,:no_courses,:storage

 validates :name,:organization_id,:price,:no_students,:no_teachers,:no_admins,:no_courses,:storage, presence: true

 belongs_to :organization
end
