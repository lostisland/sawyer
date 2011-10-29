module Sawyer
  class Relation
    attr_reader :name,
      :href,
      :method

    # Public: Builds an index of Relations from the value of a `_links`
    # property in a resource.
    #
    # index - The Hash mapping Relation names to the Hash Relation
    #         options.
    #
    # Returns a Hash mapping Relation names to Relations.
    def self.from_links(index)
      rels = {}

      index.each do |name, options|
        rel = from_link name, options
        rels[rel.name] = rel
      end

      rels
    end

    # Public: Builds a single Relation from the given options.  These are
    # usually taken from a `_links` property in a resource.
    #
    # name    - The Symbol name of the relation.
    # options - A Hash containing the other Relation properties.
    #           :_href   - The String URL of the next action's location.
    #           :_method - The optional String HTTP method.
    #
    # Returns a Relation.
    def self.from_link(name, options)
      new name, options[:_href], options[:_method]
    end

    # A Relation represents an available next action for a resource.
    #
    # name   - The Symbol name of the relation.
    # href   - The String URL of the location of the next action.
    # method - The Symbol HTTP method.  Default: :get
    def initialize(name, href, method = nil)
      @name   = name.to_sym
      @href   = href.to_s

      if method.is_a?(String)
        if method.size.zero?
          method = nil
        else
          method.downcase!
        end
      end

      @method = (method || :get).to_sym
    end
  end
end
