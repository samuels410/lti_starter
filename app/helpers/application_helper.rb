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

  def api_call(path, user_config, all_pages=false,method=nil,params=nil)
    #protocol = 'https'
    protocol = ENV['RACK_ENV'].to_s == "development" ? "http" : "https"
    host = "#{protocol}://#{user_config.host}"
    canvas = Canvas::API.new(:host => host, :token => user_config.access_token)
    begin
      if method == :post
        result = canvas.post(path,params)
      else
        result = canvas.get(path)
      end

      if result.is_a?(Array) && all_pages
        while result.more?
          result.next_page!
        end
      end
      return result
    rescue Canvas::ApiError => e
      return false
    end
  end


end
