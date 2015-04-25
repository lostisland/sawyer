require "test/unit"
require "faraday"
require_relative "../lib/sawyer"
require_relative "../lib/sawyer/adapters/faraday"
require_relative "../lib/sawyer/adapters/hurley"

class Sawyer::TestCase < Test::Unit::TestCase
  def default_test
  end
end
