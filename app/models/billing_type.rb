class BillingType < ActiveRecord::Base
   attr_accessible :organization_id, :billing_type,:discount_percentage,:months
   belongs_to :organization
end
