module Sawyer
  VERSION = "0.0.5"

  class Error < StandardError; end
end

require 'set'

%w(
  resource
  relation
  response
  serializer
  agent
).each { |f| require File.expand_path("../sawyer/#{f}", __FILE__) }
