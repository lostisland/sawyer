require File.expand_path('../helper', __FILE__)

module Sawyer
  class RelationTest < TestCase
    def test_builds_from_hash
      hash = {:name => 'self', :href => '/users/1', :method => 'get', :schema_href => '/schemas/user'}
      rel  = Sawyer::Relation.from(hash)

      hash.each do |key, value|
        assert_equal value, rel.send(key)
      end
    end

    def test_builds_from_array
      arr  = [{:name => 'self'}, {:name => 'create'}]
      rels = Sawyer::Relation.from(arr)
      arr.each_with_index do |hash, i|
        assert_equal hash[:name], rels[i].name
      end
      assert_equal arr.size, rels.size
    end

    def test_builds_from_link_header
      arr = [
        {:name => 'self', :href => '/users/1'},
        {:name => 'create', :href => '/users', :method => "GET"}
      ]

      header = %(<#{arr[0][:href]}>; rel="#{arr[0][:name]}", <#{arr[1][:href]}>; rel="#{arr[1][:name]}"; method="GET")

      rels = Sawyer::Relation.from header
      arr.each_with_index do |hash, i|
        rel = rels[i]
        hash.each do |key, value|
          assert_equal value.downcase, rel.send(key)
        end
      end
      assert_equal arr.size, rels.size
    end
  end
end

