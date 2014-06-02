class SubscriptionPlan < ActiveRecord::Base
  include Freemium::SubscriptionPlan
  attr_accessible :feature_set_id, :name, :rate_cents,:organization_id
  belongs_to :feature_set
  belongs_to :organization

  scope :free, where("rate_cents = 0")
end
