class Subscription < ActiveRecord::Base
  include Freemium::Subscription
  belongs_to :organization
  attr_accessible :organization_id,:subscription_plan_id,:subscribable_id,:subscribable_type

  SUBSCRIBABLE_TYPE_ACCOUNT = 'Account'

  # Temporary After Integrate Payment gateway have to remove ,to override default
  def paid?

  end

end