module Sawyer
  class Relation < Struct.new(:name, :href, :method, :schema_href)
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
        new options[:name], options[:href], options[:method], options[:schema_href]
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

    def inspect
      %(#<%s @name=%s @schema=%s @href="%s %s">) % [
        self.class,
        name.inspect,
        schema_href.inspect,
        method, href
      ]
    end
  end
end
