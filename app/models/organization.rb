class Organization < ActiveRecord::Base
  attr_accessible :host, :name,:url,:description,:image,:email
  has_many :external_configs

end
