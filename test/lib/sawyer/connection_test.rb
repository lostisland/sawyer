require_relative "../../helper"

module Sawyer
  class ConnectionTest < TestCase
    def test_builds_a_default_connection
      Sawyer::Connection.default.is_a?(Faraday::Connection)
    end
  end
end

