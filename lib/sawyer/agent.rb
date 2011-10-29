require 'faraday'

module Sawyer
  class Agent
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
      request :get, @endpoint
    end

    # Makes a request through Faraday.
    #
    # method - The Symbol name of an HTTP method.
    # *args  - List of arguments to pass to Faraday::Connection.
    #
    # Optionally Yields a Faraday::Request object to fine-tune the
    # request parameters.
    # Returns a Sawyer::Response.
    def request(method, *args)
      block = block_given? ? Proc.new : nil
      Response.new self, @conn.send(method, *args, &block)
    end

    def inspect
      %(<#{self.class} #{@endpoint}>)
    end
  end
end
