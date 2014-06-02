class Organization < ActiveRecord::Base
  attr_accessible :host, :name,:url,:description,:image,:email
  validate :host, :name,:url,:description,:image,:email ,presence: true

  has_many :external_configs
  has_many :feature_sets
  has_many :subscription_plans
  has_many :subscriptions

end
