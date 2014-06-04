class LtiController < ApplicationController

  before_filter :validate_lti_launch, except: [:oauth_success]

  def placement_launch
    redirect_to plans_path(organization_id: @org.id)
  end

  def session_fixed
    session['has_session'] = true
  end

  def oauth_success
    if !session['domain_id'] || !session['user_id'] || !session['source_id']
      render 'session_lost'
    end
    domain = Domain.find(session['domain_id'])
    protocol = ENV['RACK_ENV'].to_s == "development" ? "http" : "https"
    return_url = "#{protocol}://#{env['HTTP_HOST']}/oauth_success"
    code = params['code']
    url = "#{protocol}://#{domain.host}/login/oauth2/token"
    uri = URI.parse(url)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = protocol if protocol  == "https"
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data({
                              :client_id => oauth_config.value,
                              :code => code,
                              :client_secret => oauth_config.shared_secret,
                              :redirect_uri => CGI.escape(return_url)
                          })
    response = http.request(request)
    json = JSON.parse(response.body)

    if json && json['access_token']
      user_config = UserConfig.find_by_user_id_and_domain_id(session['user_id'],domain.id)
      user_config ||= UserConfig.new(:user_id => session['user_id'], :domain_id => domain.id)
      user_config.access_token = json['access_token']
      user_config.name = session['name']
      user_config.image = session['user_image']
      user_config.global_user_id = session['source_id'] + "_" + json['user']['id'].to_s
      user_config.save
      params_stash = session['params_stash']
      launch_badge_placement_config_id = session['launch_badge_placement_config_id']
      launch_course_id = session["launch_course_id"]
      permission = session["permission_for_#{launch_course_id}"]
      name = session['name']
      email = session['email']

      session.destroy
      session['user_id'] = user_config.user_id.to_s
      session['domain_id'] = user_config.domain_id.to_s.to_i
      session["permission_for_#{launch_course_id}"] = permission
      session['name'] = name
      session['email'] = email

      redirect_to plans_path
    else
      return error("Error retrieving access token")
    end
  end

end
