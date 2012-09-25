module Sawyer
  VERSION = "0.0.2"

  class Error < StandardError; end
end

require 'set'

%w(
  resource
  relation
  response
  agent
).each { |f| require File.expand_path("../sawyer/#{f}", __FILE__) }
