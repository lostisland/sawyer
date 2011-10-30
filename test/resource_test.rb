require File.expand_path("../helper", __FILE__)

module Sawyer
  class ResourceTest < TestCase
    def test_accessible_keys
      res = Resource.new :agent, :a => 1,
        :_links => {:self => {:_href => '/'}}

      assert_equal 1, res.a
      assert res.rels[:self]
      assert_equal :agent, res.agent
      assert_equal 1, res.fields.size
      assert res.fields.include?(:a)
    end

    def test_clashing_keys
      res = Resource.new :agent, :agent => 1, :rels => 2, :fields => 3,
        :_links => {:self => {:_href => '/'}}

      assert_equal 1, res.agent
      assert_equal 2, res.rels
      assert_equal 3, res.fields

      assert res._rels[:self]
      assert_equal :agent, res._agent
      assert_equal 3, res._fields.size
      [:agent, :rels, :fields].each do |f|
        assert res._fields.include?(f)
      end
    end
  end
end
