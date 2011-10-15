module Sawyer
  class Relation
    # Public: Parses the input into one or more Relation objects.
    #
    # links - Either a Hash, an Array of Hashes, or a String Link header.
    #
    # Returns a single Relation if a Hash is given, or an Array of Relations
    def self.from(links = {})
      case links
      when String
        parse_link_header(links)
      when Array
        links.map { |link| from(link) }
      when Hash
        new links[:rel] || links[:name],
          links[:href],
          links[:method],
          links[:schema] || links[:schema_href]
      else
        raise ArgumentError, "Cannot parse #{links.inspect}"
      end
    end

    # Parses a Link header into Relations.
    #
    # header - A String Link header.
    #
    # Returns an Array of Sawyer::Relation instances.
    def self.parse_link_header(header)
      header.split(",").map! do |rel_string|
        name = href = method = schema_href = nil
        pieces = rel_string.split(';')
        href   = pieces.shift.strip.gsub(/^<|>$/, '')
        pieces.each do |piece|
          piece.strip!
          if piece =~ /([^=]+)="([^"]+)"/
            case $1.to_sym
            when :rel    then name        = $2
            when :method then method      = $2
            when :schema then schema_href = $2
            end
          end
        end
        new name, href, method, schema_href
      end
    end

    attr_accessor :schema, :name, :href, :method, :schema_href

    def initialize(name, href = nil, method = nil, schema = nil)
      @schema = nil
      @name   = name
      @href   = href
      @method = (method || 'get').to_s.downcase
      @schema_href = schema
    end

    # Public: Makes an HTTP request with the options set in this relation.
    #
    # *args   - One or more optional arguments for
    #           Faraday::Connection#{method}
    #
    # Returns a Faraday::Response
    def request(*args)
      raise Sawyer::Error, "No schema for this relation: #{inspect}" unless @schema

      if agent = @schema.agent
        block = block_given? ? Proc.new : nil
        agent.request self, *args, &block
      else
        raise Sawyer::Error, "This schema has no agent: #{@schema.inspect}"
      end
    end

    # Builds resources with the given data with this Relation's Schema.
    #
    # data - Either a Hash of properties, or an Array of Hashes
    #
    # Returns either a single Sawyer::Resource or an Array of Sawyer::Resources
    def build(data)
      raise Sawyer::Error, "No schema for this relation: #{inspect}" unless @schema
      @schema.build data
    end

    # Public: Relations from a resource only give enough information to
    # identify the Relation.  This merges those incomplete Relations with the
    # properties of a Relation given in a Schema.
    #
    # Example: A resource may define an 'update' Relation in the schema:
    #
    #     {"rel": "update", "href": "/users/{id}", "method": "patch"}
    #
    # When fetching the resource directly, it only needs to specify the
    # actual URL.
    #
    #     {"rel": "update", "href": "/users/123"}
    #
    # After parsing a relation from the resource, be sure to merge it
    # with the schema relation.
    #
    #     rel = Sawyer::Relation.from(data['_links'])
    #     rel.method # => nil
    #     rel.merge(schema)
    #     rel.method # => 'patch'
    #
    # rel - A top-level Sawyer::Schema.
    #
    # Returns this same Sawyer::Relation.
    def merge(schema, top_level_schemas = {})
      if top_rel = schema.relations[@name]
        @method ||= top_rel.method
        @href   ||= top_rel.href
        @schema ||= top_rel.schema || top_level_schemas[top_rel.schema_href]
      end
      self
    end

    def inspect
      %(#<%s @name=%s @schema=%s @href="%s %s">) % [
        self.class,
        @name.inspect,
        (@schema ? @schema.href : @schema_href).inspect,
        @method, @href || '?'
      ]
    end
  end
end
