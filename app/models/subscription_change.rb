class SubscriptionChange < ActiveRecord::Base
  include Freemium::SubscriptionChange
  attr_accessible :subscribable_id,:subscribable_type, :reason, :new_subscription_plan_id, :new_rate, :original_rate,:original_subscription_plan_id
end