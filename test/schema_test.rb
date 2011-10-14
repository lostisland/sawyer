require File.expand_path('../helper', __FILE__)

module Sawyer
  class SchemaTest < TestCase
    def setup
      @schema = Sawyer::Schema.read(
        IO.read(File.expand_path("../../example/user.schema.json", __FILE__)))
    end

    def test_parses_properties
      assert_equal 'integer', @schema.properties[:id][:type]
      assert_equal [:id, :login, :created_at, :_links], @schema.properties.keys
    end

    def test_parses_relations
      assert_equal '/users', @schema.relations['all'].href
      assert_equal 'get',    @schema.relations['all'].method
      assert_equal '/schema/nigiri', @schema.relations['favorites'].schema_href
      assert_equal 'get', @schema.relations['favorites'].method
      assert_nil @schema.relations['favorites'].href
    end
  end
end


