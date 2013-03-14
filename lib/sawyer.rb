module Sawyer
  VERSION = "0.0.7"

  class Error < StandardError; end
end

require 'set'

%w(
  resource
  relation
  response
  serializer
  agent
  link_parsers/hal
).each { |f| require File.expand_path("../sawyer/#{f}", __FILE__) }
