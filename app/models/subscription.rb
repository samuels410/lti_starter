class Subscription < ActiveRecord::Base
  include Freemium::Subscription
  belongs_to :organization
  has_many :payments
  attr_accessible :organization_id,:subscription_plan_id,:subscribable_id,:subscribable_type,:expire_on

  SUBSCRIBABLE_TYPE_ACCOUNT = 'Account'

  # to override default
  def store_credit_card?

  end

  def usage
    (self.expire_on - self.paid_through).to_i
  end

end