class Organization < ActiveRecord::Base

  validates_presence_of :host, :name,:url,:image,:email

  has_many :external_configs

end
