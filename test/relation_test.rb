require File.expand_path("../helper", __FILE__)

module Sawyer
  class RelationTest < TestCase
    def test_builds_relation_from_hash
      hash = {:_href => '/users/1', :_method => 'post'}
      rel  = Sawyer::Relation.from_link(nil, :self, hash)

      assert_equal :self,      rel.name
      assert_equal '/users/1', rel.href
      assert_equal :post,      rel.method
      assert_equal [:post],    rel.available_methods.to_a
    end

    def test_builds_multiple_rels_from_multiple_methods
      index = {
        'comments' => {:_href => '/comments', :_method => 'get,post'}
      }

      rels = Sawyer::Relation.from_links(nil, index)
      assert_equal 1, rels.size
      assert_equal [:comments], rels.keys

      assert rel = rels[:comments]
      assert_equal '/comments',   rel.href
      assert_equal :get,          rel.method
      assert_equal [:get, :post], rel.available_methods.to_a
    end

    def test_builds_rels_from_hash_index
      index = {
        'self' => {:_href => '/users/1'}
      }

      rels = Sawyer::Relation.from_links(nil, index)

      assert_equal 1, rels.size
      assert_equal [:self], rels.keys
      assert rel = rels[:self]
      assert_equal :self,      rel.name
      assert_equal '/users/1', rel.href
      assert_equal :get,       rel.method
      assert_equal [:get],     rel.available_methods.to_a
    end

    def test_builds_rels_from_nil
      rels = Sawyer::Relation.from_links nil, nil
      assert_equal 0,  rels.size
      assert_equal [], rels.keys
    end

    def test_relation_api_calls
      agent = Sawyer::Agent.new "http://foo.com/a/" do |conn|
        conn.builder.handlers.delete(Faraday::Adapter::NetHttp)
        conn.adapter :test do |stubs|
          stubs.get '/a/1' do
            [200, {}, '{}']
          end
          stubs.delete '/a/1' do
            [204, {}, '{}']
          end
        end
      end

      rel = Sawyer::Relation.new agent, :self, "/a/1", "get,put,delete"
      assert_equal :get, rel.method
      [:get, :put, :delete].each do |m|
        assert rel.available_methods.include?(m), "#{m.inspect} is not available: #{rel.available_methods.inspect}"
      end

      assert_equal 200, rel.call.status
      assert_equal 200, rel.call(:method => :head).status
      assert_equal 204, rel.call(nil, :method => :delete).status
      assert_raises ArgumentError do
        rel.call nil, :method => :post
      end

      assert_equal 200, rel.head.status
      assert_equal 200, rel.get.status
      assert_equal 204, rel.delete.status

      assert_raises ArgumentError do
        rel.post
      end
    end
  end
end

