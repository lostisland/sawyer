require File.expand_path("../helper", __FILE__)

module Sawyer
  class ResponseTest < TestCase
    def setup
      @conn = Faraday.new do |builder|
        builder.adapter :test do |stub|
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

      @res = Sawyer::Response.new(@conn.get('/'))
    end

    def test_gets_status
      assert_equal 200, @res.status
    end

    def test_gets_headers
      assert_equal 'application/json', @res.headers['content-type']
    end

    def test_gets_body
      assert_equal 1, @res.data[:a]
      assert_equal [:a], @res.data.keys
    end

    def test_gets_relations
      assert_equal '/a',  @res.relations[:self].href
      assert_equal :post, @res.relations[:self].method
    end
  end
end

