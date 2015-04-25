require 'addressable/template'

module Sawyer
  class Agent
    NO_BODY = Set.new([:get, :head])

    attr_accessor :links_parser

    # Allow relations to call all the HTTP verbs, not just the ones defined.
    attr_accessor :allow_undefined_methods

    class << self
      attr_writer :serializer
    end

    def self.serializer
      @serializer ||= Serializer.any_json
    end

    def self.encode(data)
      serializer.encode(data)
    end

    def self.decode(data)
      serializer.decode(data)
    end

    # Agents handle making the requests, and passing responses to
    # Sawyer::Response.
    #
    # endpoint - String URI of the API entry point.
    # options  - Hash of options.
    #            :connection               - Optional transport connection to use.
    #                                        Default: Faraday::Connection.
    #            :links_parser             - Optional parser to parse link relations
    #                                        Defaults: Sawyer::LinkParsers::Hal.new
    #            :serializer               - Optional serializer Class.  Defaults to
    #                                        self.serializer_class.
    #
    # Yields the Faraday::Connection if a block is given.
    def initialize(endpoint, adapter, options = nil)
      @endpoint = endpoint
      @adapter    = adapter
      @serializer = (options && options[:serializer]) || self.class.serializer
      @links_parser = (options && options[:links_parser]) || Sawyer::LinkParsers::Hal.new
      @allow_undefined_methods = (options && options[:allow_undefined_methods])
    end

    # Public: Retains a reference to the root relations of the API.
    #
    # Returns a Sawyer::Relation::Map.
    def rels
      @rels ||= root.data._rels
    end

    # Public: Retains a reference to the root response of the API.
    #
    # Returns a Sawyer::Response.
    def root
      @root ||= start
    end

    # Public: Hits the root of the API to get the initial actions.
    #
    # Returns a Sawyer::Response.
    def start
      call :get, @endpoint
    end

    # Makes a request through Faraday.
    #
    # method  - The Symbol name of an HTTP method.
    # url     - The String URL to access.  This can be relative to the Agent's
    #           endpoint.
    # data    - The Optional Hash or Resource body to be sent.  :get or :head
    #           requests can have no body, so this can be the options Hash
    #           instead.
    # options - Hash of option to configure the API request.
    #           :headers - Hash of API headers to set.
    #           :query   - Hash of URL query params to set.
    #
    # Returns a Sawyer::Response.
    def call(method, url, data = nil, options = nil)
      if NO_BODY.include?(method)
        options ||= data
        data      = nil
      end

      if data
        data = data.is_a?(String) ? data : encode_body(data)
      end

      options ||= {}
      url = expand_url(url, options[:uri])
      @adapter.request(self, method, url, data, options)
    end

    # Encodes an object to a string for the API request.
    #
    # data - The Hash or Resource that is being sent.
    #
    # Returns a String.
    def encode_body(data)
      @serializer.encode(data)
    end

    # Decodes a String response body to a resource.
    #
    # str - The String body from the response.
    #
    # Returns an Object resource (Hash by default).
    def decode_body(str)
      @serializer.decode(str)
    end

    def parse_links(data)
      @links_parser.parse(data)
    end

    def expand_url(url, options = nil)
      tpl = url.respond_to?(:expand) ? url : Addressable::Template.new(url.to_s)
      tpl.expand(options || {}).to_s
    end

    def allow_undefined_methods?
      !!@allow_undefined_methods
    end

    def inspect
      %(<#{self.class} #{@endpoint}>)
    end

    # private
    def to_yaml_properties
      [:@endpoint]
    end

    def marshal_dump
      [@endpoint]
    end

    def marshal_load(dumped)
      @endpoint = *dumped.shift(1)
    end

    def self.for(endpoint, adapter: nil, &block)
      adapter = case adapter
                when NilClass, :faraday
                  require "faraday"

                  faraday = ::Faraday.new
                  yield faraday if block_given?

                  Sawyer::Adapters::Faraday.new endpoint, faraday
                when :hurley
                  require "hurley"

                  hurley = ::Hurley::Client.new endpoint
                  yield hurley if block_given?

                  Sawyer::Adapters::Hurley.new endpoint, hurley
                end

      new(endpoint, adapter)
    rescue LoadError => e
      puts e.message
    end
  end
end
