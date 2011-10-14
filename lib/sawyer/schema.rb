require 'yajl'

module Sawyer
  class Schema
    # Public: Reads a schema from the given JSON.
    #
    # json - String JSON content.
    #
    # Returns a Sawyer::Schema
    def self.read(json, href = nil)
      data = Yajl.load(json, :symbolize_keys => true)
      data[:href] = href.to_s if href
      new(data)
    end

    attr_reader   :href
    attr_accessor :all

    def initialize(data = {})
      @all  = data.delete(:all) || {}
      @href = data.delete(:href)
      @data = data
      @type = @relations = @properties = nil
    end

    # Reads raw data from a request into a Sawyer::Resource.
    #
    # json - A String.
    #
    # Returns either a single Sawyer::Resource or an Array of Sawyer::Resources
    def read(json)
      Resource.read(self, json)
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
