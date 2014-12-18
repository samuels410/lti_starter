class Organization < ActiveRecord::Base
  attr_accessible :host, :name,:url,:image,:email
  validates_presence_of :host, :name,:url,:image,:email

  has_many :external_configs

end
