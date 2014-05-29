class UserConfigsController < ApplicationController
  def index
    @user_configs = UserConfig.all
  end
end
