require 'json'

# Outputs log entries to an IO stream, one JSON hash per entry.
#
# Adds `generated_at` and `severity` fields to the hash with the current
# timestamp in milliseconds and the entry severity.
class EventLogger
  module Output
    class IO
      attr_reader :stream

      def initialize(stream)
        @stream = stream
      end

      def write(severity, details = {})
        timestamp = (Time.now.to_f * 1000).to_i
        line = JSON.generate({ generated_at: timestamp, severity: severity }.merge(details))
        @stream << "#{line}\n"
      end
    end
  end
end
