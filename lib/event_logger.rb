require 'singleton'
require 'securerandom'

require_relative 'event_logger/config'

# Event logger based on:
# https://blog.logentries.com/2015/07/ditch-the-debugger-and-use-log-analysis-instead/
class EventLogger
  attr_reader :config
  attr_accessor :mapping

  include Singleton

  def initialize
    @config = Config.new
    @mapping = nil
  end

  def self.log(*args)
    instance.log(*args)
  end

  def log(type, details = {})
    severity = if details.key?(:severity)
                 details.delete(:severity)
               elsif @mapping && @mapping.key?(details[:name])
                 @mapping[details[:name]][:severity]
               else
                 :info
               end.to_sym

    config.logger_instance.write severity, details_for(type, details)
  end

  def create_correlation_id
    SecureRandom.uuid
  end

  private

  def details_for(type, details)
    { type: type }.merge(details)
  end
end
