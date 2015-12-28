require 'singleton'
require 'logger'

class EventLogger

  attr_accessor :logger

  include Singleton

  def initialize
    @logger = Logger.new(STDOUT)
  end

  def self.log(*args)
    instance.log *args
  end

  def log(type, details = {})
    @logger.info format_log_entry(details_for(type, details))
  end

  private

    def details_for(type, details)
      { type: type }.merge(details)
    end

    def format_log_entry(details = {})
      details.map { |key, value| "#{key}=#{value}" }.join(' ')
    end
end
