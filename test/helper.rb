require "minitest/autorun"
require File.expand_path('../../lib/sawyer', __FILE__)

class Sawyer::TestCase < Minitest::Test
  def default_test
  end

  def supports_yaml?
    return true if ruby_version < yaml_disabled_version
    ENV["SAWYER_YAML_ENABLED"] == "1"
  end

  def ruby_version
    Gem::Version.new(RUBY_VERSION)
  end

  def yaml_disabled_version
    Gem::Version.new("2.5.0")
  end
end
