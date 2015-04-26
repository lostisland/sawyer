require_relative "../../helper"

describe Sawyer::Resource do

  def setup
    @stubs = Faraday::Adapter::Test::Stubs.new
    @agent = Sawyer::Agent.for "http://foo.com/a/" do |conn|
      conn.builder.handlers.delete(Faraday::Adapter::NetHttp)
      conn.adapter :test, @stubs
    end
  end

  it "accessible_keys" do
    res = Sawyer::Resource.new @agent, :a => 1,
      :_links => {:self => {:href => '/'}}

    assert_equal 1, res.a
    assert res.rels[:self]
    assert_equal @agent, res.agent
    assert_equal 1, res.fields.size
    assert res.fields.include?(:a)
  end

  it "clashing_keys" do
    res = Sawyer::Resource.new @agent, :agent => 1, :rels => 2, :fields => 3,
      :_links => {:self => {:href => '/'}}

    assert_equal 1, res.agent
    assert_equal 2, res.rels
    assert_equal 3, res.fields

    assert res._rels[:self]
    assert_equal @agent, res._agent
    assert_equal 3, res._fields.size
    [:agent, :rels, :fields].each do |f|
      assert res._fields.include?(f)
    end
  end

  it "nested_object" do
    res = Sawyer::Resource.new @agent,
      :user   => {:id => 1, :_links => {:self => {:href => '/users/1'}}},
      :_links => {:self => {:href => '/'}}

    assert_equal '/', res.rels[:self].href
    assert_kind_of Sawyer::Resource, res.user
    assert_equal 1, res.user.id
    assert_equal '/users/1', res.user.rels[:self].href
  end

  it "nested_collection" do
    res = Sawyer::Resource.new @agent,
      :users  => [{:id => 1, :_links => {:self => {:href => '/users/1'}}}],
      :_links => {:self => {:href => '/'}}

    assert_equal '/', res.rels[:self].href
    assert_kind_of Array, res.users

    assert user = res.users.first
    assert_kind_of Sawyer::Resource, user
    assert_equal 1, user.id
    assert_equal '/users/1', user.rels[:self].href
  end

  it "attribute_predicates" do
    res = Sawyer::Resource.new @agent, :a => 1, :b => true, :c => nil, :d => false

    assert  res.a?
    assert  res.b?
    assert !res.c?
    assert !res.d?
  end

  it "attribute_setter" do
    res = Sawyer::Resource.new @agent, :a => 1
    assert_equal 1, res.a
    assert !res.key?(:b)

    res.b = 2
    assert_equal 2, res.b
    assert res.key?(:b)
  end

  it "dynamic_attribute_methods_from_getter" do
    res = Sawyer::Resource.new @agent, :a => 1
    assert res.key?(:a)
    assert res.respond_to?(:a)
    assert res.respond_to?(:a=)

    assert_equal 1, res.a
    assert res.respond_to?(:a)
    assert res.respond_to?(:a=)
  end

  it "nillable_attribute_getters" do
    res = Sawyer::Resource.new @agent, :a => 1
    assert !res.key?(:b)
    assert !res.respond_to?(:b)
    assert !res.respond_to?(:b=)
    assert_nil res.b
  end

  it "dynamic_attribute_methods_from_setter" do
    res = Sawyer::Resource.new @agent, :a => 1
    assert !res.key?(:b)
    assert !res.respond_to?(:b)
    assert !res.respond_to?(:b=)

    res.b = 1
    assert res.key?(:b)
    assert res.respond_to?(:b)
    assert res.respond_to?(:b=)
  end

  it "attrs" do
    res = Sawyer::Resource.new @agent, :a => 1
    hash = {:a => 1 }
    assert_equal hash, res.attrs
  end

  it "to_h" do
    res = Sawyer::Resource.new @agent, :a => 1
    hash = {:a => 1 }
    assert_equal hash, res.to_h
  end

  it "to_attrs_for_sawyer_resource_arrays" do
    res = Sawyer::Resource.new @agent, :a => 1, :b => [Sawyer::Resource.new(@agent, :a => 2)]
    hash = {:a => 1, :b => [{:a => 2}]}
    assert_equal hash, res.to_attrs
  end

  it "handle_hash_notation_with_string_key" do
    res = Sawyer::Resource.new @agent, :a => 1
    assert_equal 1, res['a']

    res[:b] = 2
    assert_equal 2, res.b
  end

  it "simple_rel_parsing" do
    @agent.links_parser = Sawyer::LinkParsers::Simple.new
    res = Sawyer::Resource.new @agent,
      :url => '/',
      :user   => {
        :id => 1,
        :url => '/users/1',
        :followers_url => '/users/1/followers'
      }

    assert_equal '/', res.rels[:self].href
    assert_kind_of Sawyer::Resource, res.user
    assert_equal '/', res.url
    assert_equal 1, res.user.id
    assert_equal '/users/1', res.user.rels[:self].href
    assert_equal '/users/1', res.user.url
    assert_equal '/users/1/followers', res.user.rels[:followers].href
    assert_equal '/users/1/followers', res.user.followers_url
  end

  it "handle_yaml_dump" do
    require 'yaml'
    res = Sawyer::Resource.new @agent, :a => 1
    YAML.dump(res)
  end

  it "handle_marshal_dump" do
    dump = Marshal.dump(Sawyer::Resource.new(@agent, :a => 1))
    resource = Marshal.load(dump)
    assert_equal 1, resource.a
  end

  it "inspect" do
    resource = Sawyer::Resource.new @agent, :a => 1
    assert_equal "{:a=>1}", resource.inspect
  end

  it "each" do
    resource = Sawyer::Resource.new @agent, { :a => 1, :b => 2 }
    output = []
    resource.each { |k,v| output << [k,v] }
    assert_equal [[:a, 1], [:b, 2]], output
  end

  it "enumerable" do
    resource = Sawyer::Resource.new @agent, { :a => 1, :b => 2 }
    enum = resource.map
    assert_equal Enumerator, enum.class
  end
end
