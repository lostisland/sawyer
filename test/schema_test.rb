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
      assert_equal '/users', @schema.relations['list'].href
      assert_equal '/schema/nigiri', @schema.relations['favorites'].schema_href
    end
  end
end


