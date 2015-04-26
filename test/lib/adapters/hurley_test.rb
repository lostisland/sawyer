require_relative "../../helper"
require "hurley/test"

module Sawyer
  class HurleyAdapterTest < TestCase

    def setup
      @stubs = Hurley::Test.new
      endpoint = "http://foo.com/a/"
      @agent = Sawyer::Agent.for endpoint, adapter: :hurley do |hurley|
        hurley.connection = @stubs
      end
    end

    def test_it_supports_get
      @stubs.get "/" do |req|
        assert_equal "foo.com", req.url.host
        [200, {"Content-Type" => "application/json"}, "{\"color\": \"blue\"}"]
      end
      res = @agent.call :get, "/a"

      assert_equal 200, res.status
      assert_equal "blue", res.data.color
    end

    def test_it_supports_post
      @stubs.post "/widgets" do |req|
        assert_equal "foo.com", req.url.host
        assert_equal "{\"name\":\"my-widget\"}", req.body
        [
          201,
          {"Content-Type" => "application/json"},
          "{\"id\": 3, \"name\": \"my-widget\"}"
        ]
      end
      res = @agent.call :post, "/widgets", :name => "my-widget"

      assert_equal 201, res.status
      assert_equal 3, res.data.id
      assert_equal "my-widget", res.data.name
    end
  end
end

