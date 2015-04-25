module Sawyer
  class Response
    attr_reader :agent,
      :status,
      :headers,
      :data,
      :rels

    # Builds a Response after a completed request.
    #
    # agent   - The Sawyer::Agent that is managing the API connection.
    # status  - Number HTTP status code.
    # headers - Hash of HTTP response headers.
    # body    - String HTTP response body.
    # started - Time request stared.
    # ended   - Time when request ended.
    def initialize(agent, status:, headers: {}, body: res, started:, ended:)
      @agent   = agent
      @status  = status
      @headers = headers
      @data    = @headers[:content_type] =~ /json|msgpack/ ? process_data(@agent.decode_body(body)) : body
      @rels    = process_rels
      @started = started
      @ended   = ended
    end

    def timing
      @timing ||= @ended - @started
    end

    def time
      @ended
    end

    def inspect
      %(#<#{self.class}: #{@status} @rels=#{@rels.inspect} @data=#{@data.inspect}>)
    end

    private

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
      else data
      end
    end

    # Finds link relations from 'Link' response header
    #
    # Returns an array of Relations
    def process_rels
      links = ( @headers["Link"] || "" ).split(', ').map do |link|
        href, name = link.match(/<(.*?)>; rel="(\w+)"/).captures

        [name.to_sym, Relation.from_link(@agent, name, :href => href)]
      end

      Hash[*links.flatten]
    end

  end
end
