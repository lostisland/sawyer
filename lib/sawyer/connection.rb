module Sawyer
  class Connection

    def initialize(endpoint, wrapped)
      @endpoint = endpoint
      @wrapped = wrapped
    end

    def call(method, url, data = nil, options = nil)
      raise "implemented in subclasses"
    end

    def self.default
      ::Faraday::Connection.new
    end
  end
end
