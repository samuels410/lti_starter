class Subscription < ActiveRecord::Base
  include Freemium::Subscription
  belongs_to :organization
  has_many :payments
  attr_accessible :organization_id,:subscription_plan_id,:subscribable_id,:subscribable_type

  SUBSCRIBABLE_TYPE_ACCOUNT = 'Account'

  # to override default
  def store_credit_card?

  end

end