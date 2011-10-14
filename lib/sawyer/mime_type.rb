module Sawyer
  # Represents a parsed mime type.
  class MimeType
    # Initializes a mime type.
    #
    # type - String type from a header: 
    #        "application/vnd.foo+json; charset=utf-8"
    def initialize(type)
      @string = type
      @media_type = @sub_type = @suffix = @options = @vendor = nil
    end

    # Public: Gets the media type of a mime type.  This is the first segment in
    # the above type: "application"
    #
    # Returns a String.
    def media_type
      @media_type || parse_and_return(:@media_type)
    end

    # Public: Gets the sub type of a mime type.  This is the last segment in
    # the above type: "vnd.foo"
    #
    # Returns a String.
    def sub_type
      @sub_type || parse_and_return(:@sub_type)
    end

    # Public: Gets the optional suffix of a mime type.  This is the segment
    # after the `+` in the above type: "json".
    #
    # Returns a String.
    def suffix
      @suffix || parse_and_return(:@suffix)
    end

    # Public: Gets the optional vendor name of a mime type.  This is taken
    # from sub types with a `vnd.` prefix: "foo".
    #
    # Returns a String.
    def vendor
      @vendor || parse_and_return(:@vendor)
    end

    # Public: Gets whether the mime type is vendor-specific.
    #
    # Returns true or false.
    def vendor?
      !vendor.empty?
    end

    # Public: Gets the custom options for a mime type.  These are key/value
    # pairs specified after the main type: "charset=utf-8"
    #
    # Returns a Hash.
    def options
      @options || parse_and_return(:@options)
    end

    # Public: Gets the original mime type representation.
    #
    # Returns a String.
    def to_s
      @string
    end

    # Parses the given type into the various properties.  Called lazily on
    # a mime type the first time a property is accessed.
    #
    # ivar - A symbol instance variable to return to the accessor calling this.
    #
    # Returns an Object (depending on the ivar).
    def parse_and_return(ivar)
      @options = {}
      @suffix  = ''
      @vendor  = ''

      pieces = @string.split ';'

      # separate the type from the key/value options
      @media_type, @sub_type = pieces.shift.strip.split('/')

      @sub_type.sub!(/\+(.+)$/) do |s|
        @suffix = $1; nil
      end

      if @sub_type =~ /^vnd\.(.*)/
        @vendor = $1
      end

      # parse the key/value options
      pieces.each do |pair|
        key, value = pair.strip.split('=')
        options[key] = value
      end

      instance_variable_get ivar
    end

    def inspect
      %(#<%s %s>) % [
        self.class,
        @string.inspect
      ]
    end
  end
end
