class Domain < ActiveRecord::Base

  attr_accessible :host, :name
  has_many :user_configs

end
