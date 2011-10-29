require File.expand_path("../helper", __FILE__)

module Sawyer
  class AgentTest < TestCase
    def setup
      @stubs = Faraday::Adapter::Test::Stubs.new
    end

    def test_starts_a_session
      @stubs.get '/a/' do |env|
        assert_equal 'foo.com', env[:url].host

        [200, {}, Yajl.dump(
          :_links => {
            :users => {:_href => '/users'}})]
      end

      agent = Sawyer::Agent.new "http://foo.com/a/" do |http|
        http.adapter :test, @stubs
      end

      res = agent.start

      assert_equal 200, res.status
      assert_kind_of Sawyer::Resource, resource = res.data

      assert_equal '/users', resource.rels[:users].href
      assert_equal :get,     resource.rels[:users].method
    end
  end
end

