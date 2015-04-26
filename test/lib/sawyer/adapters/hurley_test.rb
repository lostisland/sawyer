require_relative "../../../helper"
require "hurley/test"

describe Sawyer::Adapters::Hurley do

  def setup
    endpoint = "http://foo.com/a/"
    @agent = Sawyer::Agent.for endpoint, adapter: :hurley
  end

  it "supports get" do
    stub_request(:get, "http://foo.com/a").
      to_return(:status => 200, :body => "{\"color\":\"blue\"}",
        :headers => { "Content-Type" => "application/json" })
    res = @agent.call :get, "/a"

    assert_equal 200, res.status
    assert_equal "blue", res.data.color
  end

  it "supports post" do
    body = "{\"id\":3,\"name\":\"my-widget\"}"
    stub_request(:post, "http://foo.com/a/widgets").
      to_return(:status => 201, :body => body,
        :headers => { "Content-Type" => "application/json" })

    res = @agent.call :post, "widgets", :name => "my-widget"

    assert_equal 201, res.status
    assert_equal 3, res.data.id
    assert_equal "my-widget", res.data.name
  end
end

