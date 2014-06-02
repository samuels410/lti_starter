module ApplicationHelper

  def check_admin_user
    unless user_signed_in? and current_user.has_role? :admin
      flash[:error] = "Not Autorized"
      redirect_to root_url
    end
  end

  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

end
