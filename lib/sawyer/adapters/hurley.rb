module Sawyer
  module Adapters
    class Hurley

      def initialize(endpoint, hurley = nil)
        @hurley = hurley || ::Hurley::Client.new(endpoint)
      end

    end
  end
end
