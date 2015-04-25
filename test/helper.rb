require "test/unit"
require "faraday"
require_relative "../lib/sawyer"
require_relative "../lib/sawyer/connection/faraday"
require_relative "../lib/sawyer/connection/hurley"

class Sawyer::TestCase < Test::Unit::TestCase
  def default_test
  end
end
