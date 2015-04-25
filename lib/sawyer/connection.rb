module Sawyer
  class Connection

    def initialize(endpoint, wrapped)
      @endpoint = endpoint
      @wrapped = wrapped
    end

    def self.default
      Faraday::Connection.new
    end
  end
end
