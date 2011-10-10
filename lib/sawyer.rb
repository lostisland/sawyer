require 'yajl'
require 'faraday'

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

  module FaradayWrapper
    def get(url = nil, headers = nil)
      block = block_given? ? Proc.new : nil
      connection.get(url, headers, &block)
    end

    def post(url = nil, body = nil, headers = nil)
      block = block_given? ? Proc.new : nil
      connection.post(url, body, headers, &block)
    end

    def put(url = nil, body = nil, headers = nil)
      block = block_given? ? Proc.new : nil
      connection.put(url, body, headers, &block)
    end

    def patch(url = nil, body = nil, headers = nil)
      block = block_given? ? Proc.new : nil
      connection.patch(url, body, headers, &block)
    end

    def head(url = nil, headers = nil)
      block = block_given? ? Proc.new : nil
      connection.head(url, nil, headers, &block)
    end

    def delete(url = nil, headers = nil)
      block = block_given? ? Proc.new : nil
      connection.delete(url, nil, headers, &block)
    end
  end

  class Agent
    include FaradayWrapper
    attr_reader :connection, :relations, :profiles

    def initialize(faraday = nil)
      @connection = faraday || Faraday::Connection.new
      @relations  = {}
      @profiles   = {}
    end

    def load(endpoint)
      @connection.url_prefix = endpoint
      res = @connection.get endpoint
      if res.status == 200
        load_schemas(res)
        nil
      else
        res
      end
    end

    def load_schemas(res)
      data = Yajl.load res.body, :symbolize_keys => true
      data[:_links].each do |link|
        load_resource profile(link[:schema]), link
      end
    end

    # options - Hash of link options.
    #           :rel - the relation of the link.
    #           :href - The String relative URL of the link.
    #          
    def load_resource(profile, options)
      @relations[options[:rel]] = Resource.new(profile, options)
    end

    def profile(url)
      @profiles[url] ||= Profile.new(self, url)
    end
  end

  class Profile
    attr_reader :agent

    def initialize(agent, url)
      @agent = agent
      @url   = url
      @type  = @relations = @properties = nil
    end

    def type
      @type || load_and_return(:@type)
    end

    def relations
      @relations || load_and_return(:@relations)
    end

    def properties
      @properties || load_and_return(:@properties)
    end

    def load_and_return(ivar)
      res = @agent.get @url
      if res.status != 200
        raise HttpError.new(res, "Unable to load profile at #{@url.inspect}")
      end      
      data        = Yajl.load res.body, :symbolize_keys => true
      @type       = data[:type]
      @relations  = data[:relations]
      @properties = data[:properties]
      instance_variable_get ivar
    end
  end

  class Resource
    def initialize(profile, options)
      @relations  = {}
      @profile    = profile
      @agent      = profile.agent
    end
  end
end
