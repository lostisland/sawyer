module Sawyer
  class MimeType
    def initialize(type)
      @string = type
      @media_type = @sub_type = @suffix = @options = @vendor = nil
    end

    def media_type
      @media_type || parse_and_return(:@media_type)
    end

    def sub_type
      @sub_type || parse_and_return(:@sub_type)
    end

    def suffix
      @suffix || parse_and_return(:@suffix)
    end

    def vendor
      @vendor || parse_and_return(:@vendor)
    end

    def vendor?
      !vendor.empty?
    end

    def options
      @options || parse_and_return(:@options)
    end

    def to_s
      @string
    end

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
        options[key.to_sym] = value
      end

      instance_variable_get ivar
    end
  end
end
