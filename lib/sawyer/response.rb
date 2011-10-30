require 'yajl'

module Sawyer
  class Response
    attr_reader :agent,
      :status,
      :headers,
      :data,
      :rels

    # Builds a Response after a completed request.
    #
    # agent - The Sawyer::Agent that is managing the API connection.
    # res   - A Faraday::Response.
    def initialize(agent, res)
      @agent   = agent
      @status  = res.status
      @headers = res.headers
      @data    = process_data(@agent.decode_body(res.body))
    end

    # Turns parsed contents from an API response into a Resource or
    # collection of Resources.
    #
    # data - Either an Array or Hash parsed from JSON.
    #
    # Returns either a Resource or Array of Resources.
    def process_data(data)
      case data
      when Hash  then Resource.new(agent, data)
      when Array then data.map { |hash| process_data(hash) }
      when nil   then nil
      else
        raise ArgumentError, "Unable to process #{data.inspect}.  Want a Hash or Array"
      end
    end

    def inspect
      %(#<#{self.class}: #{@status} @rels=#{@rels.inspect} @data=#{@data.inspect}>)
    end
  end
end
