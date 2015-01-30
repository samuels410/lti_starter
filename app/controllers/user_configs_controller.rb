class UserConfigsController < ApplicationController
  def index
    @user_configs = UserConfig.paginate(:page => params[:page], :per_page => 30)
  end

  private

  def permitted_params
    params.require(:user_config).permit(:access_token, :name,:image,:global_user_id,:user_id,:domain_id)
  end
end
