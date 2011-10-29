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
        instance_variable_set "@#{key}", value
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

