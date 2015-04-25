module Sawyer
  class Connection
    def self.default
      Faraday::Connection.new
    end
  end
end
