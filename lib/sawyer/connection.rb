module Sawyer
  class Connection

    def initialize(endpoint, wrapped)
      @endpoint = endpoint
      @wrapped = wrapped
    end

    def call(method, url, data = nil, options = nil)
      raise "implemented in subclasses"
    end

    def self.default
      ::Faraday::Connection.new
    end

    def self.build(endpoint, connection: nil, &block)
      case connection
      when NilClass, :faraday
        conn = Sawyer::Connection.build_faraday endpoint
        yield conn if block_given?

        Sawyer::Connection::Faraday.new endpoint, conn
      when :hurley
        conn = Sawyer::Connection.build_hurley endpoint
        yield conn if block_given?

        Sawyer::Connection::Hurley.new endpoint, conn
      end
    end

    def self.build_faraday(endpoint)
     require "faraday"

     faraday = ::Faraday.new endpoint
     faraday.url_prefix = endpoint

     faraday
    rescue LoadError => e
      warn "Please install faraday gem for Faraday client support"
    end

    def self.build_hurley(endpoint)
     require "hurley"

     hurley = ::Hurley::Client.new endpoint
     yield hurley if block_given?

     hurley
    rescue LoadError => e
      warn "Please install hurley gem for Hurley client support"
    end
  end
end
