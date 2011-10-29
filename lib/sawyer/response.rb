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
      @relations = Relation.from_links(@data.delete(:_links))
    end

    # Public: Makes another API request with the given relation.
    #
    # name  - Either a String relation name or a Relation.
    # *args - List of arguments to pass to Faraday::Connection.
    #
    # Optionally Yields a Faraday::Request object to fine-tune the
    # request parameters.
    # Returns a Sawyer::Response.
    def request(name, *args)
      rel = name.is_a?(Relation) ? name : @relations[name]
      if !rel
        raise ArgumentError, "#{name.inspect} is not an available Relation"
      end

      block = block_given? ? Proc.new : nil
      @agent.request rel.method, rel.href, *args, &block
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
