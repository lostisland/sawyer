require 'yajl'

module Sawyer
  class Resource
    # Reads raw data from a request into a Sawyer::Resource.
    #
    # schema - A Sawyer::Schema instance.
    # json   - A String.
    #
    # Returns either a single Sawyer::Resource or an Array of Sawyer::Resources
    def self.read(schema, json)
      data = Yajl.load(json, :symbolize_keys => true)
      case data
      when Array then data.map! { |prop| new(schema, prop) }
      when Hash  then new(schema, data)
      else raise(ArgumentError, "What is this: #{data.inspect}")
      end
    end

    attr_reader :schema, :properties, :relations

    # Gets the value of a property in this resource.
    #
    # key - A Symbol name of a property.
    #
    # Returns the Object value of the property, or nil.
    def [](key)
      @properties[key]
    end

    def initialize(schema, properties)
      @schema     = schema
      @properties = properties

      self.relations = @properties.delete(:_links)
    end

    # Parses the given links into Relations.
    #
    # links - Either an Array of Hashes or a String Link header.
    #
    # Returns a Hash mapping String names to a Sawyer::Relation.
    def relations=(links = nil)
      @relations = if links
        Relation.from(links).inject(@relations || {}) do |map, rel|
          map.update rel.name => rel.merge(@schema, @schema.all)
        end
      else
        {}
      end
    end

    def inspect
      %(#<%s @schema=%s @rels=%s %s>) % [
        self.class,
        @schema.href,
        @relations.keys.inspect,
        @properties.inspect
      ]
    end
  end
end

