require 'faraday'
require 'uri_template'

module Sawyer
  class Agent
    NO_BODY = Set.new [:get, :head]

    # Agents handle making the requests, and passing responses to
    # Sawyer::Response.
    #
    # endpoint - String URI of the API entry point.
    def initialize(endpoint)
      @endpoint = endpoint
      @conn     = Faraday.new endpoint
      yield @conn if block_given?
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

      options ||= {}
      url = URITemplate.new(url).expand(options[:uri] || {})
      res = @conn.send method, url do |req|
        req.body = encode_body(data) if data 
        if params = options[:query]
          req.params.update params
        end
        if headers = options[:headers]
          req.headers.update headers
        end
      end

      Response.new self, res
    end

    # Encodes an object to a string for the API request.
    #
    # data - The Hash or Resource that is being sent.
    #
    # Returns a String.
    def encode_body(data)
      Yajl.dump data
    end

    # Decodes a String response body to a resource.
    #
    # str - The String body from the response.
    #
    # Returns an Object resource (Hash by default).
    def decode_body(str)
      Yajl.load str, :symbolize_keys => true
    end

    def inspect
      %(<#{self.class} #{@endpoint}>)
    end
  end
end

