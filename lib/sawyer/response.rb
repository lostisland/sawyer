require 'yajl'

module Sawyer
  class Response
    attr_reader :agent,
      :status,
      :headers,
      :data,
      :relations

    # Builds a Response after a completed request.
    #
    # agent - The Sawyer::Agent that is managing the API connection.
    # res   - A Faraday::Response.
    def initialize(agent, res)
      @agent     = agent
      @status    = res.status
      @headers   = res.headers
      @data      = decode_body(res.body)
      @relations = Relation.from_links(@agent, @data.delete(:_links))
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
      %(#<#{self.class}: #{@status} @relations=#{@relations.inspect} @data=#{@data.inspect}>)
    end
  end
end
