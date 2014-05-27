module Freemium
  module Gateways
    class Test < Base
      attr_accessor :username, :password

      def transactions(options = {})
        options
      end

      def charge(*args)
        args
      end

      def store(*args)
        response = Freemium::Response.new(true)
        response.billing_key = Time.now.to_i.to_s
        response
      end

      def update(billing_key, *args)
        response = Freemium::Response.new(true)
        response.billing_key = billing_key
        response
      end

      def cancel(*args)
        args
      end

      def validate(*args)
        response = Freemium::Response.new(true)
        response
      end
    end
  end
end
