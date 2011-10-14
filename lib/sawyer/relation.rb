module Sawyer
  class Relation
    # Public: Parses the input into one or more Relation objects.
    #
    # options - Either a Hash, an Array of Hashes, or a String Link
    #           header.
    #
    # Returns a single Relation if a Hash is given, or an Array of Relations
    def self.from(options = {})
      case options
      when String
        parse_link_header(options)
      when Array
        options.map { |hash| from(hash) }
      when Hash
        new options[:rel] || options[:name],
          options[:href],
          options[:method],
          options[:schema] || options[:schema_href]
      else
        raise ArgumentError, "Cannot parse #{options.inspect}"
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

    def initialize(name, href, method, schema)
      @schema = nil
      @name   = name
      @href   = href
      @method = (method || 'get').to_s.downcase
      @schema_href = schema
    end

    # Makes an HTTP request with the options set in this relation.
    #
    # faraday - A Faraday::Connection.
    # *args   - One or more optional arguments for
    #           Faraday::Connection#{method}
    #
    # Returns a Faraday::Response
    def request(faraday, *args)
      block = block_given? ? Proc.new : nil
      faraday.send @method, @href, *args, &block
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
    #     rel.merge(schema.relations['update'])
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
