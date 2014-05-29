class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session


  def placement_launch
    get_org
    key = params['oauth_consumer_key']
    tool_config = ExternalConfig.first(:config_type => 'lti', :value => key)
    if !tool_config
      halt 400, error("Invalid tool launch - unknown tool consumer")
    end
    secret = tool_config.shared_secret
    host = params['custom_canvas_api_domain']
    if host && params['launch_presentation_return_url'].match(Regexp.new(host.sub(/\.instructure\.com/, ".(test|beta).instructure.com")))
      host = params['launch_presentation_return_url'].split(/\//)[2]
    end
    host ||= params['tool_consumer_instance_guid'].split(/\./)[1..-1].join(".") if params['tool_consumer_instance_guid'] && params['tool_consumer_instance_guid'].match(/\./)
    domain = Domain.first_or_new(:host => host)
    domain.name = params['tool_consumer_instance_name']
    domain.save
    provider = IMS::LTI::ToolProvider.new(key, secret, params)
    if !params['custom_canvas_user_id']
      halt 400, error("This app appears to have been misconfigured, please contact your instructor or administrator. App must be launched with public permission settings.")
    end
    if !params['lis_person_contact_email_primary']
      halt 400, error(lti_launchlti_launch"This app appears to have been misconfigured, please contact your instructor or administrator. Email address is required on user launches.")
    end
    if provider.valid_request?(request)
      badgeless_placement = params['custom_show_all'] || params['custom_show_course'] || params['ext_content_intended_use'] == 'navigation' || params['picker'] || params['main_navigation_show_all']
      unless badgeless_placement
        if !params['custom_canvas_course_id']
          halt 400, error("This app appears to have been misconfigured, please contact your instructor or administrator. Course must be a Canvas course, and launched with public permission settings.")
        end
        bc = BadgePlacementConfig.first_or_new(:placement_id => params['resource_link_id'], :domain_id => domain.id, :course_id => params['custom_canvas_course_id'])
        bc.external_config_id ||= tool_config.id
        bc.organization_id = tool_config.organization_id if !bc.id
        bc.organization_id ||= @org.id
        bc.settings ||= {}
        bc.settings['course_url'] = "#{BadgeHelper.protocol}://" + host + "/courses/" + params['custom_canvas_course_id']
        bc.settings['prior_resource_link_id'] = params['custom_prior_resource_link_id'] if params['custom_prior_resource_link_id']
        bc.settings['pending'] = true if !bc.id

        unless bc.settings['badge_config_already_checked']
          bc.settings['badge_config_already_checked'] = true
          if params['badge_reuse_code']
            specified_badge_config = BadgeConfig.first(:reuse_code => params['badge_reuse_code'])
            if specified_badge_config && bc.badge_config != specified_badge_config && !bc.configured?
              bc.set_badge_config(specified_badge_config)
            end
          else
            old_style_badge_config = BadgeConfig.first(:placement_id => params['resource_link_id'], :domain_id => domain.id, :course_id => params['custom_canvas_course_id'])
            if old_style_badge_config
              bc.set_badge_config(old_style_badge_config)
            end
          end
        end
        if !bc.badge_config
          conf = BadgeConfig.new(:organization_id => bc.organization_id)
          conf.settings = {}
          conf.settings['badge_name'] = params['badge_name'] if params['badge_name']
          conf.reuse_code = params['badge_reuse_code'] if params['badge_reuse_code'] && params['badge_reuse_code'].length > 20
          conf.save
          bc.badge_config = conf
        end
        bc.save
        session["launch_badge_placement_config_id"] = bc.id
        @bc = bc
      end

      user_id = params['custom_canvas_user_id']
      user_config = UserConfig.first(:user_id => user_id, :domain_id => domain.id)
      session["context_module_id"] = params['context_module_id'].to_i
      session["user_id"] = user_id
      session["user_image"] = params['user_image']
      session["launch_placement_id"] = params['resource_link_id']
      session["launch_course_id"] = params['custom_canvas_course_id']
      session["permission_for_#{params['custom_canvas_course_id']}"] = 'view'
      session['email'] = params['lis_person_contact_email_primary']

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

      # if we already have an oauth token then make sure it works
      json = CanvasAPI.api_call("/api/v1/users/self/profile", user_config) if user_config
      if user_config && json && json['id']
        user_config.image = params['user_image']
        user_config.save
        session['user_id'] = user_config.user_id

        launch_redirect((@bc && @bc.id), domain.id, user_config.user_id, params)
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
    flash[:error] = "Domain not properly configured. No Organization record matching the host #{request.env['HTTP_HOST']}"  unless @org
    render "500"
  end

  end

