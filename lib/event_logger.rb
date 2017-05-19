require 'singleton'
require 'logger'
require 'uuidtools'

# Event logger based on:
# https://blog.logentries.com/2015/07/ditch-the-debugger-and-use-log-analysis-instead/
class EventLogger
  attr_accessor :logger
  attr_accessor :mapping

  include Singleton

  def initialize
    @logger = Logger.new(STDOUT)
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
                 'info'
               end
    @logger.send(severity, format_log_entry(details_for(type, details)))
  end

  def create_correlation_id
    UUIDTools::UUID.random_create.to_s
  end

  private

  def details_for(type, details)
    { type: type }.merge(details)
  end

  def format_log_entry(details = {})
    details.map { |key, value| "#{key}=#{value}" }.join(' ')
  end
end
