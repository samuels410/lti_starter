class UserConfigsController < ApplicationController
  def index
    @user_configs = UserConfig.paginate(:page => params[:page], :per_page => 30)
  end
end
