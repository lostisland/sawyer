module Sawyer
  class Connection::Faraday < Sawyer::Connection

    def call(method, url, data = nil, options = nil)
      @wrapped.send method, url do |req|
        req.body = data if data
        if params = options[:query]
          req.params.update params
        end
        if headers = options[:headers]
          req.headers.update headers
        end
      end
    end

  end
end
