class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  include ApplicationHelper
  require 'oauth'
  require 'oauth/request_proxy/rack_request'
  require 'canvas-api'

  def validate_lti_launch
    session['no_header'] = true
    get_org
    key = params['oauth_consumer_key']
    tool_config = ExternalConfig.find_by_config_type_and_value('lti',key)
    if !tool_config
      return render(:status => 400, :json => { :message => "Invalid tool launch - unknown tool consumer" })
    end
    secret = tool_config.shared_secret
    host = params['custom_canvas_api_domain']
    if host && params['launch_presentation_return_url'].match(Regexp.new(host.sub(/\.instructure\.com/, ".(test|beta).instructure.com")))
      host = params['launch_presentation_return_url'].split(/\//)[2]
    end
    host ||= params['tool_consumer_instance_guid'].split(/\./)[1..-1].join(".") if params['tool_consumer_instance_guid'] && params['tool_consumer_instance_guid'].match(/\./)
    domain = Domain.find_or_create_by_host(host)
    domain.name = params['tool_consumer_instance_name']
    domain.save
    provider = IMS::LTI::ToolProvider.new(key, secret, params)
    if !params['custom_canvas_user_id']
      return render(:status => 400, :json => { :message => "This app appears to have been misconfigured, please contact your instructor or administrator. App must be launched with public permission settings." })
    end
    if !params['lis_person_contact_email_primary']
      return render(:status => 400, :json => { :message => "This app appears to have been misconfigured, please contact your instructor or administrator. Email address is required on user launches." })
    end
    if provider.valid_request?(request)

      user_id = params['custom_canvas_user_id']
      user_config = UserConfig.find_by_user_id_and_domain_id(user_id, domain.id)
      session["user_id"] = user_id
      session["user_image"] = params['user_image']
      session["launch_placement_id"] = params['resource_link_id']
      session["launch_course_id"] = params['custom_canvas_course_id']
      session["permission_for_#{params['custom_canvas_course_id']}"] = 'view'
      session['email'] = params['lis_person_contact_email_primary']
      session['account_id'] = params['custom_canvas_account_id']
      # TODO: something akin to this parameter needs to be sent in order to
      # tell the difference between Canvas Cloud and Canvas CV instances.
      # Otherwise I can't tell the difference between global_user_id 5 from
      # Cloud as opposed to from CV.
      session['source_id'] = params['custom_canvas_system_id'] || 'cloud'
      session['name'] = params['lis_person_name_full']
      # check if they're a teacher or not
      session["permission_for_#{params['custom_canvas_course_id']}"] = 'edit' if provider.roles.include?('instructor') || provider.roles.include?('contentdeveloper') || provider.roles.include?('urn:lti:instrole:ims/lis/administrator') || provider.roles.include?('administrator')
      session['domain_id'] = domain.id.to_s
      session['params_stash'] = hash_slice(params, 'custom_show_all', 'custom_show_course', 'ext_content_intended_use', 'picker', 'custom_canvas_course_id', 'launch_presentation_return_url', 'ext_content_return_url')
      session['custom_show_all'] = params['custom_show_all']
      session['referrer'] = request.referrer

      # if we already have an oauth token then make sure it works
      json = api_call("/api/v1/users/self/profile", user_config) if user_config
      if user_config && json && json['id']
        user_config.image = params['user_image']
        user_config.save
        session['user_id'] = user_config.user_id
        session['user_config_id'] = user_config.id
        # otherwise we need to do the oauth dance for this user
      else
        oauth_dance(request, host)
      end
    else
      return error("Invalid tool launch - invalid parameters")
    end
  end

  def get_org
    @org = Organization.find_by_host(request.env['HTTP_HOST'])
    if @org
     session['organization_id'] = @org.id
    else
      flash[:error] = "Domain not properly configured. No Organization record matching the host #{request.env['HTTP_HOST']}"
   end
  end

  def oauth_dance(request, host)
    protocol = ENV['RACK_ENV'].to_s == "development" ? "http" : "https"
    return_url = "#{protocol}://#{request.host_with_port}/oauth_success"
    redirect_to ("#{protocol}://#{host}/login/oauth2/auth?client_id=#{oauth_config.value}&response_type=code&redirect_uri=#{CGI.escape(return_url)}")
  end

  def hash_slice(hash, *keys)
    keys.each_with_object({}){|k, h| h[k] = hash[k]}
  end

  def oauth_config
    get_org
    @oauth_config = oauth_config(@org)
  end

  def oauth_config(org=nil)
    if org && org.settings['oss_oauth']
      oauth_config ||= ExternalConfig.find_by_config_type_and_organization_id('canvas_oss_oauth',org.id)
    else
      oauth_config ||= ExternalConfig.find_by_config_type('canvas_oauth')
    end

    raise "Missing oauth config" unless oauth_config
    oauth_config
  end



end

