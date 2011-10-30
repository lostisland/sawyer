module Sawyer
  class Resource
    SPECIAL_METHODS = Set.new %w(agent rels fields)
    attr_reader :_agent, :_rels, :_fields

    # Initializes a Resource with the given data.
    #
    # agent - The Sawyer::Agent that made the API request.
    # data  - Hash of key/value properties.
    def initialize(agent, data)
      @_agent  = agent
      @_rels   = Relation.from_links(agent, data.delete(:_links))
      @_fields = []
      data.each do |key, value|
        @_fields << key
        instance_variable_set "@#{key}", process_value(value)
      end
    end

    # Processes an individual value of this resource.  Hashes get exploded
    # into another Resource, and Arrays get their values processed too.
    #
    # value - An Object value of a Resource's data.
    #
    # Returns an Object to set as the value of a Resource key.
    def process_value(value)
      case value
      when Hash  then self.class.new(@_agent, value)
      when Array then value.map { |v| process_value(v) }
      else value
      end
    end

  private
    # Provides access to a resource's attributes.
    def method_missing(method, *args)
      attr_name, suffix = method.to_s.scan(/(.*)(\?|\=)?$/).first
      if value = instance_variable_get("@#{attr_name}")
        value
      elsif suffix.nil? && SPECIAL_METHODS.include?(attr_name)
        instance_variable_get "@_#{attr_name}"
      else
        super
      end
    end
  end
end

