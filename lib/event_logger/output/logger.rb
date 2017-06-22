require 'json'

# Outputs log entries to a Logger object, one JSON hash per entry.
#
# Can be used with the Ruby Logger or another that responds to per-severity
# methods.
class EventLogger
  module Output
    class Logger
      attr_reader :logger

      def initialize(logger)
        @logger = logger
      end

      def write(severity, details = {})
        @logger.public_send(severity, JSON.generate(details))
      end
    end
  end
end
