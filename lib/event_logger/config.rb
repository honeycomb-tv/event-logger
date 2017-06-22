require 'logger'

require 'event_logger/output/io'
require 'event_logger/output/logger'

class EventLogger
  class Config
    attr_reader :logger

    def initialize
      self.logger = ENV.fetch('EVENT_LOGGER_LOGGER', :logger).to_sym
    end

    def logger=(value)
      if value.is_a?(Symbol) && !%i[logger stdout].include?(value)
        raise ArgumentError, "Unknown logger type: #{value}"
      end

      @logger = value
    end

    def logger_instance
      if logger == :logger
        EventLogger::Output::Logger.new(Logger.new(STDOUT))
      elsif logger == :stdout
        EventLogger::Output::IO.new($stdout)
      elsif logger.respond_to?(:<<)
        EventLogger::Output::IO.new(logger)
      else
        EventLogger::Output::Logger.new(logger)
      end
    end
  end
end
