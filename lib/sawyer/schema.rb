require 'yajl'

module Sawyer
  class Schema
    # Public: Reads a schema from the given JSON.
    #
    # agent - The Sawyer::Agent managing this session.
    # json  - String JSON content.
    #
    # Returns a Sawyer::Schema
    def self.read(agent, json, href = nil)
      data = Yajl.load(json, :symbolize_keys => true)
      data[:href] = href.to_s if href
      new(agent, data)
    end
    
    attr_reader   :agent, :href

    def initialize(agent, data = {})
      @agent = agent
      @all   = data.delete(:all) || {}
      @href  = data.delete(:href)
      @data  = data
      @type  = @relations = @properties = nil
    end

    def all
      @agent.schemas
    end

    # Builds resources with the given data with this Schema.
    #
    # data - Either a Hash of properties, or an Array of Hashes
    #
    # Returns either a single Sawyer::Resource or an Array of Sawyer::Resources
    def build(data)
      Resource.build self, data
    end

    # Public: Gets the JSON Schema type.
    #
    # Returns a String (I'll bet money that it's "object")
    def type
      @type || load_and_return(:@type)
    end

    # Public: Gets a mapping of String relation names to Sawyer::Relations.
    #
    # Returns a Hash.
    def relations
      @relations || load_and_return(:@relations)
    end

    # Public: Gets the properties of the JSON schema.
    #
    # Returns a Hash.
    def properties
      @properties || load_and_return(:@properties)
    end

    # Public: Determines if the schema has been loaded.
    #
    # Returns a Boolean
    def loaded?
      !@data
    end

    # Parses the JSON Schema data.
    #
    # ivar - Symbol name of an instance variable to return after
    #        parsing.
    #
    # Returns an Object (Depends on the ivar).
    def load_and_return(ivar)
      @type       = @data[:type]
      @properties = @data[:properties]
      @relations  = {}
      @data[:relations].each do |options|
        rel = Relation.from(options)
        @relations[rel.name] = rel
      end
      @data = nil
      instance_variable_get ivar
    end

    def inspect
      loaded? ?
        %(#<#{self.class} @href=#{@href.inspect} @relations=#{@relations.keys.inspect}>) :
        %(#<#{self.class} @href=#{@href.inspect} (unloaded)>)
    end
  end
end
