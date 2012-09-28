require 'date'
require 'time'

module Sawyer
  class Serializer
    # Public: Wraps a serialization format for Sawyer.  Nested objects are
    # prepared for serialization (such as changing Times to ISO 8601 Strings).
    # Any serialization format that responds to #dump and #load will work.
    def initialize(format)
      @format = format
    end

    # Public: Encodes an Object (usually a Hash or Array of Hashes).
    #
    # data - Object to be encoded.
    #
    # Returns an encoded String.
    def encode(data)
      @format.dump(encode_object(data))
    end

    # Public: Decodes a String into an Object (usually a Hash or Array of
    # Hashes).
    #
    # data - An encoded String.
    #
    # Returns a decoded Object.
    def decode(data)
      decode_object(@format.load(data))
    end

    def encode_object(data)
      case data
      when Hash then encode_hash(data)
      when Array then data.map { |o| encode_object(data) }
      else data
      end
    end

    def encode_hash(hash)
      hash.keys.each do |key|
        case value = hash[key]
        when Date then hash[key] = value.to_time.utc.xmlschema
        when Time then hash[key] = value.utc.xmlschema
        end
      end
      hash
    end

    def decode_object(data)
      case data
      when Hash then decode_hash(data)
      when Array then data.map { |o| decode_object(data) }
      else data
      end
    end

    def decode_hash(hash)
      hash.keys.each do |key|
        hash[key.to_sym] = decode_hash_value(key, hash.delete(key))
      end
      hash
    end

    def decode_hash_value(key, value)
      if key =~ /^_(at|on)$/
        Time.parse(value)
      elsif value.is_a?(Hash)
        decode_hash(value)
      else
        value
      end
    end
  end
end
