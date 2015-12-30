require 'singleton'
require 'logger'
require 'uuidtools'

class EventLogger

  attr_accessor :logger
  attr_accessor :mapping

  include Singleton

  def initialize
    @logger = Logger.new(STDOUT)
    @mapping = nil
  end

  def self.log(*args)
    instance.log *args
  end

  def log(type, details = {})

    severity = 'info'
  
    unless details.has_key?(:severity)
      unless @mapping.nil?
        if @mapping.has_key?(details[:name])
          severity = @mapping[details[:name]][:severity]
        end
      end
    else
      severity = details[:severity]
      details.delete(:severity)
    end

    @logger.send(severity, format_log_entry(details_for(type, details)))
  end

  def  create_correlation_id()
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
