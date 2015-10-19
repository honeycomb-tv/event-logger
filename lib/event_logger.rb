class EventLogger
  include Singleton

  def self.log(*args)
    instance.log *args
  end

  def log(type, details = {})
    Rails.logger.info format_log_entry(details_for(type, details))
  end

  private

    def details_for(type, details)
      { type: type }.merge(details)
    end

    def format_log_entry(details = {})
      details.map { |key, value| "#{key}=#{value}" }.join(' ')
    end
end
