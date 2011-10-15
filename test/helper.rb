require 'test/unit'
require File.expand_path('../../lib/sawyer', __FILE__)

module Sawyer
  class TestCase < Test::Unit::TestCase
    class FakeAgent
      attr_reader   :schemas
      attr_accessor :links_property

      def initialize
        @schemas = {}
        @links_property = :_links
      end
    end

    def default_test
    end
  end
end

