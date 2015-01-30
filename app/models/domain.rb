class Domain < ActiveRecord::Base

  validates :host, :name, presence: true
  has_many :user_configs

end
