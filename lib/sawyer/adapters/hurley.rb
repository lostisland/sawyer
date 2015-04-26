module Sawyer
  module Adapters
    class Hurley

      def initialize(endpoint, hurley = nil)
        @hurley = hurley || ::Hurley::Client.new(endpoint)
      end

      def request(agent, method, url, data = nil, options = nil)
        options ||= {}
        started = nil
        res = @hurley.send method, url do |req|
          req.body = data if data
          if params = options[:query]
            req.query.update params
          end
          if headers = options[:headers]
            req.header.update headers
          end
          started = Time.now
        end

        Response.new agent,
          status:  res.status_code,
          headers: res.header,
          body:    res.body,
          started: started,
          ended:   Time.now
      end
    end
  end
end
