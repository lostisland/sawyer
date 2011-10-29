require File.expand_path("../helper", __FILE__)

module Sawyer
  class ResponseTest < TestCase
    def setup
      @stubs = Faraday::Adapter::Test::Stubs.new
      @agent = Sawyer::Agent.new "http://foo.com" do |conn|
        conn.builder.handlers.delete(Faraday::Adapter::NetHttp)
        conn.adapter :test, @stubs do |stub|
          stub.get '/' do
            [200, {'Content-Type' => 'application/json'}, Yajl.dump(
              :a => 1,
              :_links => {
                :self => {:_href => '/a', :_method => 'POST'}
              }
            )]
          end
        end
      end
      
      @res = @agent.start
      assert_kind_of Sawyer::Response, @res
    end

    def test_gets_status
      assert_equal 200, @res.status
    end

    def test_gets_headers
      assert_equal 'application/json', @res.headers['content-type']
    end

    def test_gets_body
      assert_equal 1, @res.data.a
      assert_equal [:a], @res.data.fields
    end

    def test_gets_relations
      assert_equal '/a',  @res.data.relations[:self].href
      assert_equal :post, @res.data.relations[:self].method
    end

    def test_makes_request_from_relation
      @stubs.post '/a' do
        [200, {}, "{}"]
      end

      rel = @res.data.relations[:self]
      res = rel.call
      assert_equal 200, @res.status
    end
  end
end

