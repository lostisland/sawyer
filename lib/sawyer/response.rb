module Sawyer
  class Response
    attr_reader :status,
      :headers,
      :data,
      :relations

    # Builds a Response after a completed request.
    #
    # res - A Faraday::Response.
    def initialize(res)
      @status    = res.status
      @headers   = res.headers
      @data      = decode_body(res.body)
      @relations = Relation.from_links(@data.delete(:_links))
    end

    # Decodes a String response body to a resource.
    #
    # str - The String body from the response.
    #
    # Returns an Object resource (Hash by default).
    def decode_body(str)
      Yajl.load str, :symbolize_keys => true
    end
  end
end
