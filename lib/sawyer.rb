module Sawyer
  VERSION = "0.0.6"

  class Error < StandardError; end
end

require 'set'

%w(
  resource
  relation
  response
  serializer
  agent
  hal_rels_parser
).each { |f| require File.expand_path("../sawyer/#{f}", __FILE__) }
