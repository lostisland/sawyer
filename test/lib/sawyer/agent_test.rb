require_relative "../../helper"
require 'faraday/adapter/test'

describe Sawyer::Agent do

  class InlineRelsParser
    def parse(data)
      links = {}
      data.keys.select {|k| k[/_url$/] }.each {|k| links[k.to_s.gsub(/_url$/, '')] = data.delete(k) }

      return data, links
    end
  end

  def setup
    @stubs = Faraday::Adapter::Test::Stubs.new
    @agent = Sawyer::Agent.for "http://foo.com/a/", adapter: :faraday do |conn|
      conn.builder.handlers.delete(Faraday::Adapter::NetHttp)
      conn.adapter :test, @stubs
    end
  end

  it "uses default connection" do
    agent = Sawyer::Agent.for "https://example.com"
    assert agent.instance_variable_get(:"@adapter").is_a? Sawyer::Adapters::Faraday
  end

  it "can use hurley" do
    agent = Sawyer::Agent.for "https://example.com", adapter: :hurley
    assert agent.instance_variable_get(:"@adapter").is_a? Sawyer::Adapters::Hurley
  end

  it "accesses root relations" do
    @stubs.get '/a/' do |env|
      assert_equal 'foo.com', env[:url].host

      [200, {'Content-Type' => 'application/json'}, Sawyer::Agent.encode(
        :_links => {
          :users => {:href => '/users'}})]
    end

    assert_equal 200, @agent.root.status

    assert_equal '/users', @agent.rels[:users].href
    assert_equal :get,     @agent.rels[:users].method
  end

  it "allows custom rel parsing" do
    @stubs.get '/a/' do |env|
      assert_equal 'foo.com', env[:url].host

      [200, {'Content-Type' => 'application/json'}, Sawyer::Agent.encode(
        :url => '/',
        :users_url => '/users',
        :repos_url => '/repos')]
    end

    agent = Sawyer::Agent.for "http://foo.com/a/" do |conn|
      conn.builder.handlers.delete(Faraday::Adapter::NetHttp)
      conn.adapter :test, @stubs
    end
    agent.links_parser = InlineRelsParser.new

    assert_equal 200, agent.root.status

    assert_equal '/users', agent.rels[:users].href
    assert_equal :get,     agent.rels[:users].method
    assert_equal '/repos', agent.rels[:repos].href
    assert_equal :get,     agent.rels[:repos].method

  end

  it "saves root endpoint" do
    @stubs.get '/a/' do |env|
      [200, {}, '{}']
    end

    assert_kind_of Sawyer::Response, @agent.root
    refute_equal @agent.root.time, @agent.start.time
  end

  it "starts a session" do
    @stubs.get '/a/' do |env|
      assert_equal 'foo.com', env[:url].host

      [200, {'Content-Type' => 'application/json'}, Sawyer::Agent.encode(
        :_links => {
          :users => {:href => '/users'}})]
    end

    res = @agent.start

    assert_equal 200, res.status
    assert_kind_of Sawyer::Resource, resource = res.data

    assert_equal '/users', resource.rels[:users].href
    assert_equal :get,     resource.rels[:users].method
  end

  it "requests with body and options" do
    @stubs.post '/a/b/c' do |env|
      assert_equal '{"a":1}', env[:body]
      assert_equal 'abc',     env[:request_headers]['x-test']
      assert_equal 'foo=bar', env[:url].query
      [200, {}, "{}"]
    end

    res = @agent.call :post, 'b/c' , {:a => 1},
      :headers => {"X-Test" => "abc"},
      :query   => {:foo => 'bar'}
    assert_equal 200, res.status
  end

  it "requests with body and options to get" do
    @stubs.get '/a/b/c' do |env|
      assert_nil env[:body]
      assert_equal 'abc',     env[:request_headers]['x-test']
      assert_equal 'foo=bar', env[:url].query
      [200, {}, "{}"]
    end

    res = @agent.call :get, 'b/c' , {:a => 1},
      :headers => {"X-Test" => "abc"},
      :query   => {:foo => 'bar'}
    assert_equal 200, res.status
  end

  it "encodes and decodes times" do
    time = Time.at(Time.now.to_i)
    data = {
      :a => 1,
      :b => true,
      :c => 'c',
      :created_at => time,
      :published_at => nil,
      :updated_at => "An invalid date",
      :pub_date => time,
      :subscribed_at => time.to_i,
      :lost_at => time.to_f,
      :first_date => false,
      :validate => true
    }
    data = [data.merge(:foo => [data])]
    encoded = Sawyer::Agent.encode(data)
    decoded = Sawyer::Agent.decode(encoded)

    2.times do
      assert_equal 1, decoded.size
      decoded = decoded.shift

      assert_equal 1, decoded[:a]
      assert_equal true, decoded[:b]
      assert_equal 'c', decoded[:c]
      assert_equal time, decoded[:created_at], "Did not parse created_at as Time"
      assert_nil decoded[:published_at]
      assert_equal "An invalid date", decoded[:updated_at]
      assert_equal time, decoded[:pub_date], "Did not parse pub_date as Time"
      assert_equal true, decoded[:validate]
      assert_equal time, decoded[:subscribed_at], "Did not parse subscribed_at as Time"
      assert_equal time, decoded[:lost_at], "Did not parse lost_at as Time"
      assert_equal false, decoded[:first_date], "Parsed first_date"
      decoded = decoded[:foo]
    end
  end

  it "does not encode non json content types" do
    @stubs.get '/a/' do |env|
      assert_equal 'foo.com', env[:url].host

      [200, {'Content-Type' => 'text/plain'}, "This is plain text"]
    end
    res = @agent.call :get, '/a/',
      :headers => {"Accept" => "text/plain"}
    assert_equal 200, res.status

    assert_equal "This is plain text", res.data
  end

  it "handle yaml dump and load" do
    require 'yaml'
    res = Sawyer::Agent.for 'http://example.com'
    YAML.load(YAML.dump(res))
  end

  it "handle marshal dump and load" do
    res = Sawyer::Agent.for 'http://example.com'
    Marshal.load(Marshal.dump(res))
  end

  it "blank response doesnt raise" do
    @stubs.get "/a/" do |env|
      assert_equal "foo.com", env[:url].host
      [200, { "Content-Type" => "application/json" }, " "]
    end

    agent = Sawyer::Agent.for "http://foo.com/a/" do |conn|
      conn.adapter :test, @stubs
    end

    assert_equal 200, agent.root.status
  end
end
