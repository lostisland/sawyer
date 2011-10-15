require 'test/unit'
require File.expand_path('../../lib/sawyer', __FILE__)

module Sawyer
  class TestCase < Test::Unit::TestCase
    class FakeAgent < Struct.new :schemas
    end

    def default_test
    end
  end
end

