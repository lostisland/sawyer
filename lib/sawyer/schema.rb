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
    
    attr_reader :agent, :href
    attr_writer :links_property

    # agent - The Sawyer::Agent managing this session.
    # data  - A Hash parsed from a JSON Schema.
    def initialize(agent, data = {})
      @agent = agent
      @href  = data.delete(:href)
      @data  = data
      @type  = @relations = @properties = @links_property = @default_relation = nil
    end

    # Public: Builds resources with the given data with this Schema.
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

    # Public: Gets all of the loaded Schemas for this API.
    #
    # Returns a Hash of String URL keys and Sawyer::Schema values.
    def all
      @agent.schemas
    end

    # Determines what property of a resource contains the Array of links to
    # be processed.  Default: Sawyer::Agent#links_property
    #
    # Returns a Symbol.
    def links_property
      @links_property || @agent.links_property
    end

    # Determines the default Relation name in a Schema that signifies the
    # top level collection of the resource.  Default:
    # Sawyer::Agent#default_relation
    #
    # Returns a String
    def default_relation
      @default_relation || @agent.default_relation
    end

    # Sets the default Relation.
    #
    # s - The String name of the Relation.
    #
    # Returns the frozen String name.
    def default_relation=(s)
      @default_relation = s.to_s.freeze
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
