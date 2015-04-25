module Sawyer
  module Adapters
    class Faraday

      def initialize(endpoint, faraday = nil)
        @faraday = faraday || ::Faraday.new
        @faraday.url_prefix = endpoint
      end

      def request(agent, method, url, data = nil, options = nil)
        started = nil
        res = @faraday.send method, url do |req|
          req.body = data if data
          if params = options[:query]
            req.params.update params
          end
          if headers = options[:headers]
            req.headers.update headers
          end
          started = Time.now
        end

        Response.new agent, res, :sawyer_started => started, :sawyer_ended => Time.now
      end
    end
  end
end
