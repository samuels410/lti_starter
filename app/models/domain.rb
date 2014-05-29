class Domain < ActiveRecord::Base

  attr_accessible :host, :name
  validates :host, :name, presence: true
  has_many :user_configs

end
