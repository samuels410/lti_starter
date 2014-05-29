require 'canvas-api'


module CanvasAPI
    def self.api_call(path, user_config, all_pages=false)
    #protocol = 'https'
    protocol = ENV['RACK_ENV'].to_s == "development" ? "http" : "https"
    host = "#{protocol}://#{user_config.host}"
    canvas = Canvas::API.new(:host => host, :token => user_config.access_token)
    begin
      result = canvas.get(path)
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

module OAuthConfig
  def self.oauth_config(org=nil)
    if org && org.settings['oss_oauth']
      oauth_config ||= ExternalConfig.first(:config_type => 'canvas_oss_oauth', :organization_id => org.id)
    else
      oauth_config ||= ExternalConfig.first(:config_type => 'canvas_oauth')
    end
    
    raise "Missing oauth config" unless oauth_config
    oauth_config
  end
end
