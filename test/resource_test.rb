require File.expand_path('../helper', __FILE__)

module Sawyer
  class ResourceTest < TestCase
    def setup
      @schema = Sawyer::Schema.read \
        IO.read(File.expand_path("../../example/user.schema.json", __FILE__))
      yield @schema if block_given?
      @resource = @schema.read \
        %({"id": 1, "login": "bob", "_links":[{"rel":"fave", "href":"/users/1/faves"}]})
    end

    def test_knows_schema
      assert_equal @schema, @resource.schema
    end

    def test_parses_properties
      assert_equal 1,     @resource[:id]
      assert_equal 'bob', @resource[:login]
    end

    def test_parses_relations
      assert_equal 1, @resource.relations.size
      assert_equal '/users/1/faves', @resource.relations['fave'].href
      assert_equal 'get',            @resource.relations['fave'].method
      assert_nil @resource.relations['fave'].schema
    end

    def test_gets_relation_schema_from_schema_rel
      other_schema = nil
      setup do |schema|
        rel = schema.relations['fave'] = Sawyer::Relation.new("fave", 'href', 'post')
        rel.schema = other_schema = Sawyer::Schema.read(
          IO.read(File.expand_path("../../example/nigiri.schema.json", __FILE__)))
      end

      assert_equal '/users/1/faves', @resource.relations['fave'].href
      assert_equal 'get',            @resource.relations['fave'].method
      assert_equal other_schema, @resource.relations['fave'].schema
    end
  end
end

