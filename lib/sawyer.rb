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
end

%w(
  mime_type
  relation
  schema
  resource
).each { |f| require File.expand_path("../sawyer/#{f}", __FILE__) }
