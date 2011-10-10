require 'yajl'
require 'faraday'

module Sawyer
  VERSION = "0.0.1"

  class Error < StandardError; end

  class HttpError < Error
    attr_reader :response

    def initialize(response, message)
      @response = response
      super message
    end
  end

  module FaradayWrapper
    def get(url = nil, headers = nil)
      block = block_given? ? Proc.new : nil
      connection.get(url, headers, &block)
    end

    def post(url = nil, body = nil, headers = nil)
      block = block_given? ? Proc.new : nil
      connection.post(url, body, headers, &block)
    end

    def put(url = nil, body = nil, headers = nil)
      block = block_given? ? Proc.new : nil
      connection.put(url, body, headers, &block)
    end

    def patch(url = nil, body = nil, headers = nil)
      block = block_given? ? Proc.new : nil
      connection.patch(url, body, headers, &block)
    end

    def head(url = nil, headers = nil)
      block = block_given? ? Proc.new : nil
      connection.head(url, nil, headers, &block)
    end

    def delete(url = nil, headers = nil)
      block = block_given? ? Proc.new : nil
      connection.delete(url, nil, headers, &block)
    end
  end

  class Agent
    include FaradayWrapper
    attr_reader :connection, :endpoint, :content_type, :relations, :schemas

    def initialize(endpoint, faraday = nil)
      @connection = faraday || Faraday::Connection.new
      @relations  = {}
      @schemas    = {}

      @connection.url_prefix = endpoint
      res = @connection.get endpoint

      if res.status == 200
        @endpoint     = endpoint
        @content_type = res.headers['content-type']
        load_schemas(res)
        nil
      else
        res
      end
    end

    def loaded?
      !@endpoint.to_s.empty?
    end

    def schema(url)
      @schemas[url] ||= Schema.new(self, url)
    end

    def load_schemas(res)
      data = Yajl.load res.body, :symbolize_keys => true
      data[:_links].each do |link|
        load_resource schema(link[:schema]), link
      end
    end

    # options - Hash of link options.
    #           :rel - the relation of the link.
    #           :href - The String relative URL of the link.
    #          
    def load_resource(schema, options)
      @relations[options[:rel]] = Relation.new(schema, options)
    end

    def inspect
      %(#<#{self.class} @endpoint=#{@endpoint.inspect} @content_type=#{@content_type.inspect} @relations=#{@relations.keys.inspect} @schemas=#{@schemas.keys.inspect}>)
    end
  end

  class Schema
    attr_reader :url, :agent

    def initialize(agent, url)
      @agent = agent
      @url   = url
      @type  = @relations = @properties = nil
    end

    def type
      @type || load_and_return(:@type)
    end

    def relations
      @relations || load_and_return(:@relations)
    end

    def properties
      @properties || load_and_return(:@properties)
    end

    def loaded?
      @type && @relations && @properties
    end

    def load_and_return(ivar)
      res = @agent.get @url
      if res.status != 200
        raise HttpError.new(res, "Unable to load schema at #{@url.inspect}")
      end      
      data        = Yajl.load res.body, :symbolize_keys => true
      @type       = data[:type]
      @properties = data[:properties]
      @relations  = {}
      data[:relations].each do |options|
        rel = Relation.new(self, options)
        @relations[rel.name] = rel
      end
      instance_variable_get ivar
    end

    def inspect
      loaded? ?
        %(#<#{self.class} @url=#{@url.inspect} @relations=#{@relations.keys.inspect}>) :
        %(#<#{self.class} @url=#{@url.inspect} (unloaded)>)
    end
  end

  class Relation
    attr_reader :name, :href, :method, :schema, :agent

    def initialize(schema, options)
      @name    = options[:rel]
      @href    = options[:href].to_s
      @method  = options[:method] || 'get'
      @agent   = schema.agent
      @schema = if uri = options[:schema]
        schema.agent.schema(uri)
      else
        schema
      end

      if rel = @href.empty? && @schema.relations[@name]
        @href = rel.href
      end
    end

    def inspect
      %(#<#{self.class} @name=#{name.inspect} @schema=#{@schema.url.inspect} @href="#{@method} #{@href}">)
    end
  end
end
